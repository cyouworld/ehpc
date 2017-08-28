#! /usr/bin/env python
# -*- coding: utf-8 -*-
import json
import os
import zipfile
import shutil
from xlrd import open_workbook
from datetime import datetime

from flask import render_template, request, redirect, url_for, abort, jsonify, current_app, make_response, send_file, send_from_directory
from flask_login import current_user
from flask_babel import gettext
from sqlalchemy import or_
from threading import Thread

from . import admin
from .. import db
from ..models import Classify, Program, Paper, Question, PaperQuestion, Homework, HomeworkUpload, HomeworkAppendix, HomeworkScore, Notice
from ..models import Course, Lesson, Material, User, Apply, VNCKnowledge, VNCTask
from ..models import Knowledge, Challenge, Group
from ..user.authorize import teacher_login
from ..util.file_manage import upload_img, upload_file, get_file_type, custom_secure_filename, extension_to_file_type
from ..util.new_api import init_evaluate_program
from ..util.pdf import get_paper_pdf
from ..util.file_manage import remove_dirs
from ..util.xlsx import get_member_xlsx, get_score_xlsx, get_allscore_xlsx, get_not_uploaded_xlsx
from ..util.course_filter import check_upload, homework_uploaded


'''add_sidebar():定义上下文处理器，便于把数据导入后台管理模板中的sidebar
'''


@admin.context_processor
def add_sidebar():
    if current_user.is_authenticated and current_user.permissions == 2:
        courses = current_user.teacher_courses.order_by(Course.nature_order.asc()).all()
        courses += current_user.assistant_courses.all()
        classifies = current_user.teacher_classify
        return {'sidebar_courses': courses, 'sidebar_classifies': classifies}
    else:
        return {}


@admin.route('/course/', methods=['GET', 'POST'])
@teacher_login
def course():
    if request.method == 'GET':
        all_courses = current_user.teacher_courses.order_by(Course.nature_order.asc()).all()
        all_courses += current_user.assistant_courses.all()
        return render_template('admin/course/index.html', all_courses=all_courses, title=gettext('Course Admin'))
    elif request.method == 'POST':
        if request.form['op'] == 'del':
            # 删除课程
            curr_course = Course.query.filter_by(id=request.form['course_id']).first_or_404()
            for l in curr_course.lessons:
                for m in l.materials:
                    db.session.delete(m)
                db.session.delete(l)
            for h in curr_course.homeworks:
                for x in h.uploads:
                    db.session.delete(x)
                for x in h.appendix:
                    db.session.delete(x)
                db.session.delete(h)
            for p in curr_course.papers:
                db.session.delete(p)
            for c in curr_course.comments:
                db.session.delete(c)
            if curr_course.qrcode:
                db.session.delete(curr_course.qrcode)

            resource_path = os.path.join(current_app.config['RESOURCE_FOLDER'], 'course_%d' % curr_course.id)
            homework_path = os.path.join(current_app.config['HOMEWORK_UPLOAD_FOLDER'], 'course_%d' % curr_course.id)
            homework_appendix_path = os.path.join(current_app.config['HOMEWORK_APPENDIX_FOLDER'], 'course_%d' % curr_course.id)
            cover_path = os.path.join(current_app.config['COURSE_COVER_FOLDER'], 'cover_%d.png' % curr_course.id)
            remove_dirs(resource_path, homework_path, homework_appendix_path, cover_path)

            # 将排在此课程后面的课程序号全部减1
            total_courses = Course.query.order_by(Course.nature_order.asc())
            for c in total_courses:
                if c.nature_order >= curr_course.nature_order:
                    c.nature_order -= 1
            db.session.delete(curr_course)
            db.session.commit()
            return jsonify(status="success", course_id=curr_course.id)
        elif request.form['op'] == 'seq':
            seq = json.loads(request.form['seq'])
            for c in current_user.teacher_courses:
                c.nature_order = seq[str(c.id)]
            db.session.commit()
            return jsonify(status='success')


@admin.route('/course/create/', methods=['GET', 'POST'])
@teacher_login
def course_create():
    if request.method == 'GET':
        return render_template('admin/course/create.html',
                               title=gettext('Create Course'))
    elif request.method == 'POST':
        # 创建课程
        idx = Course.query.count()
        course_group = Group(title=request.form['title'], about=request.form['title'] + u' 的课程讨论',
                             logo='/static/upload/group_logo/default.png')
        db.session.add(course_group)
        db.session.commit()

        curr_course = Course(title=request.form['title'], subtitle='', about='',
                             lessonNum=0, smallPicture='upload/course/noImg.jpg', group_id=course_group.id,  nature_order=idx+1)
        curr_course.teacher = current_user
        db.session.add(curr_course)

        db.session.commit()
        os.makedirs(os.path.join(current_app.config['RESOURCE_FOLDER'], 'course_%d' % curr_course.id))
        os.makedirs(os.path.join(current_app.config['HOMEWORK_UPLOAD_FOLDER'], 'course_%d' % curr_course.id))
        return redirect(url_for('admin.course_edit', course_id=curr_course.id))


@admin.route('/course/<int:course_id>/edit/', methods=['GET', 'POST'])
@teacher_login
def course_edit(course_id):
    if request.method == 'GET':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        return render_template('admin/course/edit.html', course=curr_course,
                               title=gettext('Edit Course'))
    elif request.method == 'POST':
        # 编辑课程基本信息
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        curr_course.title = request.form['title']
        curr_course.subtitle = request.form['subtitle']
        curr_course.about = request.form['about']
        db.session.commit()
        return jsonify(status="success", course_id=curr_course.id)


@admin.route('/course/<int:course_id>/hide/')
@teacher_login
def course_hide(course_id):
    # 隐藏或显示课程
    curr_course = Course.query.filter_by(id=course_id).first_or_404()
    if not curr_course.is_hidden:
        curr_course.is_hidden = True
    else:
        curr_course.is_hidden = False
    db.session.commit()
    return redirect(url_for('admin.course', tag2='course-manage'))


@admin.route('/course/<int:course_id>/picture/', methods=['GET', 'POST'])
@teacher_login
def course_picture(course_id):
    if request.method == 'GET':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        return render_template('admin/course/picture.html', course=curr_course,
                               title=gettext('Course Picture'))
    elif request.method == 'POST':
        # 上传图片和保存图片
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        curr_course.smallPicture = os.path.join('upload/course', "cover_%d.png" % curr_course.id)
        filename = "cover_%d.png" % curr_course.id
        cover_path = os.path.join(current_app.config['COURSE_COVER_FOLDER'], filename)
        status = upload_img(request.files['pic'], 171, 304, cover_path)
        if status[0]:
            db.session.commit()
            return jsonify(status='success')
        else:
            return jsonify(status="fail")


@admin.route('/course/<int:course_id>/notice/', methods=['GET', 'POST'])
@teacher_login
def course_notice(course_id):
    if request.method == 'GET':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        notices = Notice.query.filter_by(course=curr_course).order_by(Notice.createdTime.desc()).all()
        return render_template('admin/course/notice.html',
                               title=gettext('Course Notice'),
                               notices=notices,
                               course=curr_course)


@admin.route('/course/<int:course_id>/notice/create', methods=['GET', 'POST'])
@teacher_login
def course_notice_create(course_id):
    if request.method == 'GET':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        return render_template('admin/course/notice_edit.html', course=curr_course,
                               title=gettext('Course Notice'))
    elif request.method == 'POST':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        new_notice = Notice(title=request.form['title'], content=request.form['content'])
        db.session.add(new_notice)
        curr_course.notices.append(new_notice)
        db.session.commit()
        return redirect(url_for('admin.course_notice', course_id=course_id))


@admin.route('/course/<int:course_id>/notice/edit/<int:notice_id>', methods=['GET', 'POST'])
@teacher_login
def course_notice_edit(course_id, notice_id):
    if request.method == 'GET':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        curr_notice = Notice.query.filter_by(id=notice_id).first_or_404()
        return render_template('admin/course/notice_edit.html',
                               course=curr_course,
                               notice=curr_notice,
                               title=gettext('Course Notice'))
    elif request.method == 'POST':
        curr_notice = Notice.query.filter_by(id=notice_id).first_or_404()
        curr_notice.title = request.form['title']
        curr_notice.content = request.form['content']
        db.session.commit()
        return redirect(url_for('admin.course_notice', course_id=course_id))


@admin.route('/course/<int:course_id>/notice/del', methods=['GET', 'POST'])
@teacher_login
def course_notice_del(course_id):
    curr_course = Course.query.filter_by(id=course_id).first_or_404()
    curr_notice = Notice.query.filter_by(id=request.form['notice_id']).first_or_404()
    curr_course.notices.remove(curr_notice)
    db.session.delete(curr_notice)
    db.session.commit()
    return jsonify(status="success")


@admin.route('/course/<int:course_id>/lesson/', methods=['GET', 'POST'])
@teacher_login
def course_lesson(course_id):
    if request.method == 'GET':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        return render_template('admin/course/lesson.html',
                               title=gettext('Course Lesson'),
                               lessons=curr_course.lessons,
                               course=curr_course)
    elif request.method == 'POST':
        # 课时的增删查改
        if request.form['op'] == 'create':
            curr_course = Course.query.filter_by(id=course_id).first_or_404()
            curr_lesson = Lesson(number=course_id, title=request.form['title'], content=request.form['content'])
            db.session.add(curr_lesson)
            curr_course.lessons.append(curr_lesson)
            curr_course.lessonNum += 1
            db.session.commit()
            return jsonify(status="success", id=curr_lesson.id)
        elif request.form['op'] == "edit":
            curr_course = Course.query.filter_by(id=course_id).first_or_404()
            curr_lesson = curr_course.lessons.filter_by(id=request.form['lesson_id']).first_or_404()
            curr_lesson.title = request.form['title']
            curr_lesson.content = request.form['content']
            db.session.commit()
            return jsonify(status="success", id=curr_lesson.id)
        elif request.form['op'] == "del":
            curr_course = Course.query.filter_by(id=course_id).first_or_404()
            curr_lesson = curr_course.lessons.filter_by(id=request.form['lesson_id']).first_or_404()
            curr_course.lessons.remove(curr_lesson)
            curr_course.lessonNum -= 1
            for m in curr_lesson.materials:
                os.remove(os.path.join(current_app.config['RESOURCE_FOLDER'], m.uri))
                db.session.delete(m)
            db.session.delete(curr_lesson)
            db.session.commit()
            return jsonify(status="success", id=curr_lesson.id)
        elif request.form['op'] == 'data':
            curr_lesson = Lesson.query.filter_by(id=request.form['lesson_id']).first_or_404()
            return jsonify(status="success", title=curr_lesson.title, content=curr_lesson.content)


@admin.route('/course/<int:course_id>/lesson/<int:lesson_id>/material/', methods=['GET', 'POST'])
@teacher_login
def lesson_material(course_id, lesson_id):
    if request.method == 'GET':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        curr_lesson = curr_course.lessons.filter_by(id=lesson_id).first_or_404()
        return render_template('admin/course/material.html', course=curr_course,
                               lesson=curr_lesson,
                               materials=curr_lesson.materials,
                               title=gettext('Lesson Material'))
    elif request.method == 'POST':
        # 课时材料的上传和删除
        if request.form['op'] == "del":
            curr_course = Course.query.filter_by(id=course_id).first_or_404()
            curr_lesson = curr_course.lessons.filter_by(id=lesson_id).first_or_404()
            material_id = request.form.getlist('material_id[]')
            for idx in material_id:
                curr_material = curr_lesson.materials.filter_by(id=idx).first()
                if not curr_material:
                    return jsonify(status="fail", id=curr_lesson.id)
                # 需要在课时对象中删除该资源
                curr_lesson.materials.remove(curr_material)
                db.session.delete(curr_material)
                db.session.commit()
                try:
                    os.remove(os.path.join(current_app.config['RESOURCE_FOLDER'], curr_material.uri))
                except OSError:
                    pass
            return jsonify(status="success", lesson_id=curr_lesson.id)
        elif request.form['op'] == 'local-upload':
            cur_course = Course.query.filter_by(id=course_id).first_or_404()
            cur_lesson = cur_course.lessons.filter_by(id=lesson_id).first_or_404()
            raw_file = request.files['file']
            file_name = custom_secure_filename(raw_file.filename)
            extension = file_name[file_name.rfind('.')+1:]
            file_type = extension_to_file_type(extension)
            cur_material = Material(name=file_name, m_type=file_type, uri="")
            cur_lesson.materials.append(cur_material)
            db.session.commit()  # get material id
            cur_material.uri = os.path.join("course_%d" % course_id,
                                            "lesson%d_material%d.%s" % (lesson_id, cur_material.id, extension))
            status = upload_file(raw_file, os.path.join(current_app.config['RESOURCE_FOLDER'], cur_material.uri),
                                 ['audio', 'video', 'pdf'])
            if status[0]:
                db.session.commit()
                return jsonify(status="success")
            else:
                cur_lesson.materials.remove(cur_material)
                db.session.delete(cur_material)
                db.session.commit()
                return jsonify(status="fail")
        elif request.form['op'] == "link-upload":
            curr_course = Course.query.filter_by(id=course_id).first_or_404()
            curr_lesson = curr_course.lessons.filter_by(id=lesson_id).first_or_404()
            if request.form['link-type'] == "origin":
                m_link = request.form['file-link']
                m_name = request.form['file-name']
                m_type = request.form['file-type']
                curr_material = Material(name=m_name, m_type=m_type, uri=m_link)
                db.session.add(curr_material)
                curr_lesson.materials.append(curr_material)
                db.session.commit()
                return jsonify(status="success", id=curr_lesson.id)


@admin.route('/course/<int:course_id>/permission/', methods=['GET', 'POST'])
@teacher_login
def course_permission(course_id):
    if request.method == 'GET':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        teachers = User.query.filter_by(permissions=2).all()
        return render_template('admin/course/permission.html', course=curr_course, teachers=teachers, title=u'权限管理')
    elif request.method == 'POST':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        if request.form.get('op') is not None:
            op = request.form.get('op')
            user_id = request.form.get('user_id')
            u = User.query.filter_by(id=user_id).first()
            if op == 'add':
                curr_course.assistants.append(u)
            elif op == 'del':
                curr_course.assistants.remove(u)
            db.session.commit()
        else:
            curr_course.public = int(request.form['public'])
            if curr_course.public:
                curr_course.beginTime = None
                curr_course.endTime = None
            else:
                curr_course.beginTime = datetime.strptime(request.form['begin'], '%Y-%m-%d %X')
                curr_course.endTime = datetime.strptime(request.form['end'], '%Y-%m-%d %X')
            db.session.commit()
        return jsonify(status="success", course_id=course_id)


@admin.route('/course/<int:course_id>/member/', methods=['GET', 'POST'])
@teacher_login
def course_member(course_id):
    if request.method == 'GET':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        search_content = request.args.get("search_content", None)
        if search_content is None:
            return render_template('admin/course/member.html',
                                   course=curr_course,
                                   applies=curr_course.applies,
                                   title=u'成员管理')
        else:
            return render_template('admin/course/member.html',
                                   course=curr_course,
                                   applies=curr_course.applies,
                                   title=u'成员管理',
                                   search_content=search_content)
    elif request.method == 'POST':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()

        member_field = request.form.getlist('member-field')
        required_field = []
        if 'name' in member_field:
            required_field.append(u'姓名')
        if 'stu-id' in member_field:
            required_field.append(u'学号')
        if 'gender' in member_field:
            required_field.append(u'性别')
        if 'telephone' in member_field:
            required_field.append(u'电话')
        if 'e-mail' in member_field:
            required_field.append(u'邮箱')

        #data = [[x.student_id, x.name, u'男' if x.gender else u'女', x.phone, x.email] for x in curr_course.users]
        uri = get_member_xlsx(curr_course.users, required_field, curr_course.id)
        download_file_name = "%s_学生名单.xlsx" % curr_course.title.encode('utf-8')
        return send_file(uri, as_attachment=True, attachment_filename=download_file_name)


@admin.route('/course/kick/<int:cid>/<int:uid>/')
@teacher_login
def public_kick_student(cid, uid):
    u = User.query.filter_by(id=uid).first_or_404()
    course_joined = Course.query.filter_by(id=cid).first_or_404()

    course_joined.users.remove(u)
    course_joined.studentNum -= 1

    if u in course_joined.group.members:
        course_joined.group.members.remove(u)
        course_joined.group.memberNum -= 1

    db.session.commit()

    return redirect(url_for('admin.course_member', course_id=cid))


@admin.route('/course/<int:apply_id>/approved/')
@teacher_login
def course_approved(apply_id):
    curr_apply = Apply.query.filter_by(id=apply_id).first_or_404()
    curr_apply.status = 1
    curr_course = curr_apply.course
    curr_student = curr_apply.user
    curr_course.users.append(curr_student)
    curr_course.studentNum += 1

    if curr_student not in curr_course.group.members:
        curr_course.group.members.append(curr_student)
        curr_course.group.memberNum += 1

    db.session.commit()
    return jsonify(status='success')


@admin.route('/course/<int:apply_id>/kick/')
@teacher_login
def course_kick(apply_id):
    curr_apply = Apply.query.filter_by(id=apply_id).first_or_404()
    curr_apply.status = 0
    curr_course = curr_apply.course
    curr_student = curr_apply.user
    curr_course.users.remove(curr_student)
    curr_course.studentNum -= 1

    if curr_student in curr_course.group.members:
        curr_course.group.members.remove(curr_student)
        curr_course.group.memberNum -= 1

    db.session.commit()
    return jsonify(status='success')


@admin.route('/course/<int:apply_id>/del/')
@teacher_login
def course_del(apply_id):
    curr_apply = Apply.query.filter_by(id=apply_id).first_or_404()
    if curr_apply.status == 0:
        db.session.delete(curr_apply)
        db.session.commit()
        return jsonify(status='success')
    else:
        abort(403)


@admin.route('/course/batch/', methods=['POST'])
@teacher_login
def course_batch():
    op = request.form['op']
    idx = request.form.getlist('id[]')
    if op == 'approve':
        for x in idx:
            curr_apply = Apply.query.filter_by(id=x).first()
            if curr_apply.status == 0:
                curr_apply.status = 1
                curr_course = curr_apply.course
                curr_student = curr_apply.user
                curr_course.users.append(curr_student)
                curr_course.studentNum += 1
                if curr_student not in curr_course.group.members:
                    curr_course.group.members.append(curr_student)
                    curr_course.group.memberNum += 1
        db.session.commit()
    elif op == 'kick':
        for x in idx:
            curr_apply = Apply.query.filter_by(id=x).first()
            if curr_apply.status == 1:
                curr_apply.status = 0
                curr_course = curr_apply.course
                curr_student = curr_apply.user
                curr_course.users.remove(curr_student)
                curr_course.studentNum -= 1
                if curr_student in curr_course.group.members:
                    curr_course.group.members.remove(curr_student)
                    curr_course.group.memberNum -= 1
        db.session.commit()
    elif op == 'del':
        for x in idx:
            curr_apply = Apply.query.filter_by(id=x).first_or_404()
            if curr_apply.status == 0:
                db.session.delete(curr_apply)
        db.session.commit()
    return jsonify(status='success')


@admin.route('/course/<int:course_id>/homework/', methods=['GET', 'POST'])
@teacher_login
def course_homework(course_id):
    """ 课程的作业管理入口页面 """
    if request.method == 'GET':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        return render_template('admin/course/homework.html', course=curr_course,
                               homeworks=curr_course.homeworks,
                               title=gettext('Course Homework'))
    elif request.method == "POST":
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        # 作业的删除
        if request.form['op'] == "del":
            curr_homework = curr_course.homeworks.filter_by(id=request.form['homework_id']).first_or_404()
            for a in curr_homework.appendix:
                curr_homework.appendix.remove(a)
                db.session.delete(a)

            for u in curr_homework.uploads:
                curr_homework.uploads.remove(u)
                db.session.delete(u)

            for s in curr_homework.homework_scores:
                curr_homework.homework_scores.remove(s)
                db.session.delete(s)

            for p in curr_homework.program:
                curr_homework.program.remove(p)
                if request.form["program"] == "del":
                    for s in p.submit_programs:
                        p.submit_programs.remove(s)
                        db.session.delete(s)
                    db.session.delete(p)

            homework_path = os.path.join(current_app.config['HOMEWORK_APPENDIX_FOLDER'], "course_%d/homework_%d" %
                                         (curr_homework.course.id, curr_homework.id))
            homework_upload_path = os.path.join(current_app.config['HOMEWORK_UPLOAD_FOLDER'], "course_%d/homework_%d" %
                                         (curr_homework.course.id, curr_homework.id))
            remove_dirs(homework_path, homework_upload_path)

            curr_course.homeworks.remove(curr_homework)
            db.session.delete(curr_homework)
            db.session.commit()

            return jsonify(status="success", homework_id=curr_homework.id)
        elif request.form['op'] == 'download-score':
            all_users = curr_course.users
            all_homework = curr_course.homeworks
            uri = get_allscore_xlsx(all_users, all_homework, curr_course.id)
            download_file_name = "%s_score" % curr_course.title.encode('utf-8')
            return jsonify(status="success", download_file_name=download_file_name)
        elif request.form['op'] == 'search':
            #查找某位学生的未交作业情况
            stu_info = request.form['stu_info']
            curr_stu = curr_course.users.filter_by(student_id=stu_info).first()
            if not curr_stu:
                return jsonify(status="not-found")
            all_homework = curr_course.homeworks.order_by(Homework.id.asc())
            not_upload = []
            for h in all_homework:
                if not homework_uploaded(h.id, curr_stu.id):
                    not_upload.append(h.title)

            return jsonify(status="success", stu_name=curr_stu.name, not_upload=not_upload)
        else:
            return abort(404)


@admin.route('/course/<int:course_id>/homework/create', methods=['GET', 'POST'])
@teacher_login
def course_homework_create(course_id):
    """ 课程的作业新创建入口页面 """
    if request.method == 'GET':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        all_program = Program.query.filter_by(user_id=current_user.id).all()
        return render_template('admin/course/homework_edit.html',
                               course=curr_course,
                               option="create",
                               all_program=all_program,
                               title=gettext('Course Homework Create'))
    elif request.method == 'POST':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        all_program = Program.query.filter_by(user_id=current_user.id).all()
        if request.form['op'] == "del":
            curr_appendix = HomeworkAppendix.query.filter_by(id=request.form['appendix_id']).first_or_404()
            curr_homework = curr_appendix.homework
            curr_homework.appendix.remove(curr_appendix)
            db.session.delete(curr_appendix)
            db.session.commit()
            try:
                os.remove(os.path.join(current_app.config['HOMEWORK_APPENDIX_FOLDER'], curr_appendix.uri))
            except OSError:
                pass
            return jsonify(status="success")

        if request.form['homework-save-op'] == "upload":
            if request.form['homework-id']:
                curr_homework = Homework.query.filter_by(id=request.form["homework-id"]).first_or_404()
            else:
                curr_homework = Homework(course_id=course_id)
                curr_course.homeworks.append(curr_homework)
                db.session.add(curr_homework)
                db.session.commit()
                os.makedirs(os.path.join(current_app.config['HOMEWORK_UPLOAD_FOLDER'], 'course_%d' % curr_course.id,
                                     'homework_%d' % curr_homework.id))
                os.makedirs(os.path.join(current_app.config['HOMEWORK_APPENDIX_FOLDER'], 'course_%d' % curr_course.id,
                                     'homework_%d' % curr_homework.id))
            appendix_files = request.files

            cnt = 0
            upload_names = []
            upload_ids = []
            upload_uris = []
            while (cnt < len(appendix_files)):
                index = 'file[%d]' % cnt
                appendix = appendix_files[index]

                file_name = custom_secure_filename(appendix.filename)
                extension = file_name[file_name.rfind('.') + 1:]
                file_type = extension_to_file_type(extension)
                cur_appendix = HomeworkAppendix(name=file_name, homework_id=curr_homework.id, user_id=current_user.id, uri="")
                current_user.homework_appendix.append(cur_appendix)
                curr_homework.appendix.append(cur_appendix)
                db.session.commit()  # get appendix id
                cur_appendix.uri = os.path.join("course_%d" % course_id,
                                            "homework_%d/appendix_%d.%s" % (curr_homework.id, cur_appendix.id, extension))
                upload_path = unicode(os.path.join(current_app.config['HOMEWORK_APPENDIX_FOLDER'], cur_appendix.uri), 'utf-8')
                status = upload_file(appendix, upload_path, ['video', 'pdf',  'wrap'])
                if status[0]:
                    db.session.commit()
                    upload_ids.append(cur_appendix.id)
                    upload_names.append(cur_appendix.name)
                    upload_uris.append(cur_appendix.uri)
                else:
                    current_user.homework_appendix.remove(cur_appendix)
                    curr_homework.appendix.remove(cur_appendix)
                    db.session.delete(cur_appendix)
                    db.session.commit()
                    for m in curr_homework.appendix:
                        current_user.homework_appendix.remove(m)
                        curr_homework.appendix.remove(m)
                        db.session.delete(m)
                        db.session.commit()
                        try:
                            os.remove(os.path.join(current_app.config['HOMEWORK_APPENDIX_FOLDER'], m.uri))
                        except OSError:
                            pass
                    return render_template('admin/course/homework_edit.html',
                                           course=curr_course,
                                           option="create",
                                           msg=gettext("homework appendix upload failed"),
                                           title=gettext('Course Homework Create'))
                cnt = cnt + 1
            return jsonify(homework_id=curr_homework.id,
                           new_upload_id=upload_ids,
                           new_upload_name=upload_names,
                           new_upload_uri=upload_uris)
        elif request.form["homework-save-op"] == "save":
            if request.form['homework-id']:
                curr_homework = Homework.query.filter_by(id=request.form["homework-id"]).first_or_404()
                curr_homework.deadline = request.form["deadline"]
                curr_homework.description = request.form["description"]
                curr_homework.title = request.form["title"]
                curr_homework.h_type = request.form['homework-type']
                if request.form["homework-type"] == "1":
                    program_list = request.form.getlist("homework-program")
                    for p_id in program_list:
                        curr_program = Program.query.filter_by(id=p_id).first_or_404()
                        curr_homework.program.append(curr_program)
                db.session.commit()
            else:
                curr_homework = Homework(title=request.form['title'],
                                         h_type=request.form['homework-type'],
                                         description=request.form['description'],
                                         course_id=course_id)
                curr_course.homeworks.append(curr_homework)
                db.session.add(curr_homework)
                db.session.commit()
                if request.form["deadline"]:
                    curr_homework.deadline = request.form['deadline']
                    db.session.commit()
                if request.form["homework-type"] == "1":
                    program_list = request.form.getlist("homework-program")
                    for p_id in program_list:
                        curr_program = Program.query.filter_by(id=p_id).first_or_404()
                        curr_homework.program.append(curr_program)
                    db.session.commit()
                os.makedirs(os.path.join(current_app.config['HOMEWORK_UPLOAD_FOLDER'], 'course_%d' % curr_course.id,
                                     'homework_%d' % curr_homework.id))
                os.makedirs(os.path.join(current_app.config['HOMEWORK_APPENDIX_FOLDER'], 'course_%d' % curr_course.id,
                                     'homework_%d' % curr_homework.id))

            tag1 = "course-%d" % course_id
            tag2 = "course-%d-5" % course_id
            return redirect(url_for("admin.course_homework",
                                    course_id=curr_course.id,
                                    tag1=tag1,
                                    tag2=tag2))


@admin.route('/course/<int:course_id>/homework/<int:homework_id>/edit', methods=['GET', 'POST'])
@teacher_login
def course_homework_edit(course_id, homework_id):
    """ 课程的作业编辑入口页面 """
    if request.method == 'GET':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        curr_homework = Homework.query.filter_by(id=homework_id).first_or_404()
        all_program = Program.query.filter_by(user_id=current_user.id).all()
        return render_template('admin/course/homework_edit.html',
                               course=curr_course,
                               option="edit",
                               homework=curr_homework,
                               all_program=all_program,
                               title=gettext('Course Homework Edit'))

    elif request.method == 'POST':
        if request.form['op'] == "del":
            curr_appendix = HomeworkAppendix.query.filter_by(id=request.form['appendix_id']).first_or_404()
            curr_homework = curr_appendix.homework
            curr_homework.appendix.remove(curr_appendix)
            db.session.delete(curr_appendix)
            db.session.commit()
            try:
                os.remove(os.path.join(current_app.config['HOMEWORK_APPENDIX_FOLDER'], curr_appendix.uri))
            except OSError:
                pass
            return jsonify(status="success")

        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        curr_homework = Homework.query.filter_by(id=homework_id).first_or_404()
        if request.form['homework-save-op'] == "upload":
            cnt = 0
            upload_names = []
            upload_ids = []
            upload_uris = []
            appendix_files = request.files
            while (cnt < len(appendix_files)):
                index = 'file[%d]' % cnt
                appendix = appendix_files[index]
                file_name = custom_secure_filename(appendix.filename)
                extension = file_name[file_name.rfind('.') + 1:]
                cur_appendix = HomeworkAppendix(name=file_name, homework_id=curr_homework.id, user_id=current_user.id,
                                                uri="")
                current_user.homework_appendix.append(cur_appendix)
                curr_homework.appendix.append(cur_appendix)
                db.session.commit()  # get appendix id
                cur_appendix.uri = os.path.join("course_%d" % course_id,
                                                "homework_%d/appendix_%d.%s" % (
                                                curr_homework.id, cur_appendix.id, extension))
                upload_path = unicode(os.path.join(current_app.config['HOMEWORK_APPENDIX_FOLDER'], cur_appendix.uri),
                                      'utf-8')
                status = upload_file(appendix, upload_path, ['video', 'pdf', 'wrap'])
                if status[0]:
                    db.session.commit()
                    upload_ids.append(cur_appendix.id)
                    upload_names.append(cur_appendix.name)
                    upload_uris.append(cur_appendix.uri)
                else:
                    current_user.homework_appendix.remove(cur_appendix)
                    curr_homework.appendix.remove(cur_appendix)
                    db.session.delete(cur_appendix)
                    db.session.commit()
                    for m in appendix_files:
                        for app in curr_homework.appendix:
                            if app.name == custom_secure_filename(m):
                                current_user.homework_appendix.remove(m)
                                curr_homework.appendix.remove(m)
                                db.session.delete(m)
                                db.session.commit()
                                try:
                                    os.remove(os.path.join(current_app.config['HOMEWORK_APPENDIX_FOLDER'], m.uri))
                                except OSError:
                                    pass
                    return render_template('admin/course/homework_edit.html',
                                           course=curr_course,
                                           option="edit",
                                           homework=curr_homework,
                                           msg=gettext("homework appendix upload failed"),
                                           title=gettext('Course Homework edit'))
                cnt = cnt + 1
            return jsonify(homework_id=curr_homework.id,
                           new_upload_id=upload_ids,
                           new_upload_name=upload_names,
                           new_upload_uri=upload_uris)

        elif request.form["homework-save-op"] == "save":
            curr_homework.title = request.form['title']
            curr_homework.description = request.form['description']
            curr_homework.deadline = request.form['deadline']
            curr_homework.h_type = request.form["homework-type"]
            if request.form["homework-type"] == "1":
                for p in curr_homework.program:
                    curr_homework.program.remove(p)
                db.session.commit()
                program_list = request.form.getlist("homework-program")
                for p_id in program_list:
                    curr_program = Program.query.filter_by(id=p_id).first_or_404()
                    curr_homework.program.append(curr_program)
            else:
                curr_programs = curr_homework.program
                for p in curr_programs:
                    curr_homework.program.remove(p)
            db.session.commit()
            tag1 = "course-%d" % course_id
            tag2 = "course-%d-5" % course_id
            all_program = Program.query.filter_by(user_id=current_user.id).all()
            return render_template('admin/course/homework_edit.html',
                                   course=curr_course,
                                   option="edit",
                                   homework=curr_homework,
                                   all_program=all_program,
                                   tag1=tag1,
                                   tag2=tag2,
                                   msg=gettext("save homework successfully"),
                                   title=gettext('Course Homework Edit'))


@admin.route('/course/<int:course_id>/homework/<int:homework_id>', methods=['GET', 'POST'])
@teacher_login
def course_homework_upload_list(course_id, homework_id):
    if request.method == "GET":
        curr_homework = Homework.query.filter_by(id=homework_id).first_or_404()
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        return render_template('admin/course/homework_upload.html',
                               course=curr_course,
                               homework=curr_homework,
                               uploads=curr_homework.uploads,
                               title=gettext("Course Homework"))
    elif request.method == "POST":
        curr_homework = Homework.query.filter_by(id=homework_id).first_or_404()
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        if request.form['op'] == "del":
            upload_id = request.form.getlist('upload_id[]')
            for idx in upload_id:
                curr_upload = curr_homework.uploads.filter_by(id=idx).first()
                if not curr_upload:
                    return jsonify(status="fail", info="Not Found")
                curr_user_uploads = curr_homework.uploads.filter_by(user_id=curr_upload.user.id).all()
                curr_user_uploads_count = len(curr_user_uploads)
                if curr_user_uploads_count == 1:
                    curr_homework_score = HomeworkScore.query.filter_by(user_id=curr_upload.user.id, homework_id=curr_homework.id).first()
                    if curr_homework_score:
                        db.session.delete(curr_homework_score)
                curr_homework.uploads.remove(curr_upload)
                db.session.delete(curr_upload)
                db.session.commit()
                try:
                    os.remove(os.path.join(current_app.config['HOMEWORK_UPLOAD_FOLDER'], curr_upload.uri))
                except OSError:
                    return jsonify(status="fail")
            return jsonify(status="success")
        elif request.form["op"] == "download":
            upload_id = request.form.getlist('upload_id[]')
            zip_name = "homework_%d.zip" % curr_homework.id
            f = zipfile.ZipFile(zip_name, 'w', zipfile.ZIP_DEFLATED)
            for idx in upload_id:
                curr_upload = curr_homework.uploads.filter_by(id=idx).first()
                file_path = os.path.join(current_app.config['HOMEWORK_UPLOAD_FOLDER'], curr_upload.uri)
                try:
                    file_dowload_name = "%s_%s_%s" % (curr_upload.user.student_id, curr_upload.user.name, curr_upload.name)
                    f.write(file_path, file_dowload_name)
                except OSError:
                    pass
            f.close()
            dest_path = os.path.join(current_app.config['HOMEWORK_UPLOAD_FOLDER'], "course_%d" % curr_course.id, "homework_%d" % curr_homework.id)
            if os.path.exists(os.path.join(dest_path, "homework_%d.zip" % curr_homework.id)):
                os.remove(os.path.join(dest_path, "homework_%d.zip" % curr_homework.id))
            shutil.move(zip_name, dest_path)
            file_name = os.path.join("course_%d" % curr_course.id, "homework_%d.zip" % curr_homework.id)
            return jsonify(status="success",
                           homework_title=curr_homework.title,
                           course_title=curr_course.title)


@admin.route('/course/<int:course_id>/homework/<int:homework_id>/not_uploaded', methods=['GET', 'POST'])
@teacher_login
def course_homework_not_uploaded(course_id, homework_id):
    curr_homework = Homework.query.filter_by(id=homework_id).first_or_404()
    curr_course = Course.query.filter_by(id=course_id).first_or_404()
    not_uploaded = []
    all_members = curr_course.users
    for u in all_members:
        if not homework_uploaded(homework_id, u.id):
            not_uploaded.append(u)
    if request.method == "GET":
        return render_template('admin/course/homework_not_uploaded.html',
                               course=curr_course,
                               homework=curr_homework,
                               not_uploaded=not_uploaded,
                               title=gettext("Course Homework"))
    elif request.method == "POST":
        uri = get_not_uploaded_xlsx(not_uploaded, curr_course.id, curr_homework.id)
        download_file_name = "%s_%s_未交名单" % (curr_course.title.encode('utf-8'), curr_homework.title.encode('utf-8'))
        return jsonify(status="success", download_file_name=download_file_name)


@admin.route('/course/<int:course_id>/homework/<int:homework_id>/correct', methods=['GET', 'POST'])
@teacher_login
def course_homework_correct(course_id, homework_id):
    curr_course = Course.query.filter_by(id=course_id).first_or_404()
    curr_homework = Homework.query.filter_by(id=homework_id).first_or_404()
    if request.method == "GET":
        return render_template('admin/course/homework_correct.html',
                               course=curr_course,
                               homework=curr_homework,
                               title=gettext('Homework Correct'))
    elif request.method == 'POST':
        if request.form['op'] == 'set':
            score = request.form['homework_score']
            comment = request.form['homework_comment']
            user_id = request.form['user_id']
            upload_status = 2
            if curr_homework.h_type == 1:
                if homework_uploaded(homework_id, user_id):
                    upload_status = 0
                else:
                    upload_status = 2
            else:
                his_upload = HomeworkUpload.query.filter_by(user_id=user_id, homework_id=homework_id).order_by(HomeworkUpload.submit_time.asc()).first()
                if not his_upload:
                    upload_status = 2
                else:
                    if his_upload.submit_time > curr_homework.deadline:
                        upload_status = 1
                    else:
                        upload_status = 0
            curr_homework_score = HomeworkScore(user_id=user_id, homework_id=homework_id, score=score, comment=comment, status=upload_status)
            db.session.add(curr_homework_score)
            db.session.commit()
            return jsonify(status="success")
        elif request.form['op'] == 'reset':
            score = request.form['homework_score']
            comment = request.form['homework_comment']
            user_id = request.form['user_id']
            curr_homework_score = HomeworkScore.query.filter_by(user_id=user_id, homework_id=homework_id).first_or_404()
            curr_homework_score.score = score
            curr_homework_score.comment = comment
            db.session.commit()
            return jsonify(status="success")
        elif request.form['op'] == 'download-score':
            all_users = curr_course.users
            uri = get_score_xlsx(all_users, curr_course.id, curr_homework.id)
            download_file_name = "%s_%s_score" % (curr_course.title.encode('utf-8'), curr_homework.title.encode('utf-8'))
            return jsonify(status="success", download_file_name=download_file_name)
        elif request.form['op'] == 'upload-score':
            score_excel = request.files['score-file']
            upload_path = unicode(os.path.join(current_app.config['HOMEWORK_UPLOAD_FOLDER'],
                                               "course_%d" % curr_course.id, "homework_%d" % curr_homework.id, 'score-upload.xls'), 'utf-8')
            status = upload_file(score_excel, upload_path)
            if status[0]:
                wb = open_workbook(upload_path)
                sheet = wb.sheets()[0]
                number_of_rows = sheet.nrows
                number_of_columns = sheet.ncols
                for row in range(1, number_of_rows):
                    curr_row = []
                    for col in range(number_of_columns):
                        curr_row.append(sheet.cell(row, col).value)
                    curr_student = User.query.filter_by(student_id=curr_row[0], name=curr_row[1]).first_or_404()
                    homework_score = HomeworkScore.query.filter_by(user_id=curr_student.id, homework_id=homework_id).first()
                    if not homework_score:
                        if curr_student in curr_course.users:
                            upload_status = 2
                            if curr_homework.h_type == 1:
                                if homework_uploaded(homework_id, curr_student.id):
                                    upload_status = 0
                                else:
                                    upload_status = 2
                            else:
                                his_upload = HomeworkUpload.query.filter_by(user_id=curr_student.id, homework_id=homework_id).order_by(HomeworkUpload.submit_time.asc()).first()
                                if not his_upload:
                                    upload_status = 2
                                else:
                                    if his_upload.submit_time > curr_homework.deadline:
                                        upload_status = 1
                                    else:
                                        upload_status = 0
                            homework_score = HomeworkScore(user_id=curr_student.id, homework_id=homework_id,
                                                           score=curr_row[2], comment=curr_row[3], status=upload_status)
                            db.session.add(homework_score)
                            db.session.commit()
                    else:
                        homework_score.score = curr_row[2]
                        homework_score.comment = curr_row[3]
                        db.session.commit()
                return jsonify(status="success")
            else:
                return jsonify(status="fail")


@admin.route('/course/<int:course_id>/paper/', methods=['GET', 'POST'])
@teacher_login
def course_paper(course_id):
    """ 课程cid 的试卷管理入口页面 """
    if request.method == 'GET':
        curr_course = Course.query.filter_by(id=course_id).first_or_404()
        return render_template('admin/course/paper.html', course=curr_course,
                               papers=curr_course.papers,
                               title=gettext('Course Paper'))
    elif request.method == 'POST':
        # 试卷的增加查改
        if request.form['op'] == 'create':
            curr_paper = Paper(title=request.form['title'], about=request.form['content'])
            curr_course = Course.query.filter_by(id=course_id).first_or_404()
            curr_course.papers.append(curr_paper)
            db.session.add(curr_paper)
            db.session.commit()
            return jsonify(status="success", paper_id=curr_paper.id)
        elif request.form['op'] == "del":
            curr_course = Course.query.filter_by(id=course_id).first_or_404()
            curr_paper = curr_course.papers.filter_by(id=request.form['paper_id']).first_or_404()
            curr_course.papers.remove(curr_paper)
            db.session.delete(curr_paper)
            db.session.commit()
            return jsonify(status="success", paper_id=curr_paper.id)
        elif request.form['op'] == "edit":
            curr_course = Course.query.filter_by(id=course_id).first_or_404()
            curr_paper = curr_course.papers.filter_by(id=request.form['paper_id']).first_or_404()
            curr_paper.title = request.form['title']
            curr_paper.about = request.form['content']
            db.session.commit()
            return jsonify(status="success", paper_id=curr_paper.id)
        elif request.form['op'] == 'data':
            curr_paper = Paper.query.filter_by(id=request.form['paper_id']).first_or_404()
            return jsonify(status="success", title=curr_paper.title, content=curr_paper.about)
        else:
            return abort(404)


@admin.route('/course/<int:course_id>/paper/<int:paper_id>/edit/', methods=['GET', 'POST'])
@teacher_login
def paper_edit(course_id, paper_id):
    """ 课程cid 的试卷 pid 对应的题目列表入口页面 """
    if request.method == 'GET':
        curr_cour = Course.query.filter_by(id=course_id).first_or_404()
        curr_paper = curr_cour.papers.filter_by(id=paper_id).first_or_404()
        tag1 = "course-%d" % course_id
        tag2 = "course-%d-6" % course_id
        return render_template('admin/course/question.html',
                               tag1=tag1,
                               tag2=tag2,
                               course=curr_cour,
                               paper=curr_paper,
                               title=gettext('Course Paper'))
    elif request.method == 'POST':
        # 试题的增删查改
        if os.path.exists(os.path.join(current_app.config['DOWNLOAD_FOLDER'], 'paper%d.pdf' % paper_id)):
            os.remove(os.path.join(current_app.config['DOWNLOAD_FOLDER'], 'paper%d.pdf' % paper_id))
        if request.form['op'] == 'create':
            curr_paper = Paper.query.filter_by(id=paper_id).first_or_404()
            curr_question = Question(type=request.form['type'], content=request.form['content'],
                                     solution=request.form['solution'], analysis=request.form['analysis'])
            aux = PaperQuestion(point=request.form['point'])
            aux.questions = curr_question
            db.session.add(aux)
            curr_paper.questions.append(aux)
            classifies = request.form.getlist('classify')
            for x in classifies:
                curr_question.classifies.append(Classify.query.filter_by(id=x).first_or_404())
            db.session.add(curr_question)
            db.session.commit()
            return redirect(url_for('admin.paper_edit', course_id=curr_paper.course.id, paper_id=curr_paper.id))
        elif request.form['op'] == 'edit':
            curr_paper = Paper.query.filter_by(id=paper_id).first_or_404()
            aux = curr_paper.questions.filter_by(question_id=request.form['question_id']).first_or_404()
            aux.point = request.form['point']
            curr_question = aux.questions
            curr_question.type = request.form['type']
            curr_question.content = request.form['content']
            curr_question.solution = request.form['solution']
            curr_question.analysis = request.form['analysis']
            for x in xrange(len(curr_question.classifies)):
                curr_question.classifies.pop(0)
            classifies = request.form.getlist('classify')
            for x in classifies:
                curr_question.classifies.append(Classify.query.filter_by(id=x).first_or_404())
            db.session.commit()
            return redirect(url_for('admin.paper_edit', course_id=curr_paper.course.id, paper_id=curr_paper.id))
        elif request.form['op'] == 'del':
            curr_paper = Paper.query.filter_by(id=paper_id).first_or_404()
            question_id = request.form.getlist('question_id[]')
            for idx in question_id:
                aux = curr_paper.questions.filter_by(question_id=idx).first_or_404()
                curr_paper.questions.remove(aux)
                curr_question = aux.questions
                db.session.delete(curr_question)
                db.session.delete(aux)
            db.session.commit()
            return jsonify(status="success", paper_id=curr_paper.id)
        else:
            return abort(404)


@admin.route('/problem/')
@teacher_login
def problem():
    return render_template('admin/problem/index.html', classify=current_user.teacher_classify,
                           questions=current_user.teacher_questions,
                           programs=current_user.teacher_program,
                           title=gettext("Question Manage"))


@admin.route('/problem/<question_type>/', methods=['GET', 'POST'])
@teacher_login
def question(question_type):
    if request.method == 'GET':
        questions = None
        if question_type == 'choice':
            questions = current_user.teacher_questions.filter(or_(Question.type == 0, Question.type == 1, Question.type == 2))
        elif question_type == 'judge':
            questions = current_user.teacher_questions.filter_by(type=4)
        elif question_type == 'fill':
            questions = current_user.teacher_questions.filter_by(type=3)
        elif question_type == 'essay':
            questions = current_user.teacher_questions.filter_by(type=5)
        return render_template('admin/problem/question.html',
                               title=gettext('Question Manage'),
                               questions=questions,
                               type=question_type)
    elif request.method == 'POST':
        # 删除练习题目
        curr_question = Question.query.filter_by(id=request.form['id']).first_or_404()
        db.session.delete(curr_question)
        db.session.commit()
        return jsonify(status="success", question_id=curr_question.id)


@admin.route('/problem/<question_type>/<int:question_classify>/', methods=['GET', 'POST'])
@teacher_login
def question_filter_by_classify(question_type, question_classify):
    if request.method == 'GET':
        questions = None
        if question_type == 'choice':
            questions = Classify.query.filter_by(id=question_classify).first().questions.filter(or_(Question.type == 0, Question.type == 1, Question.type == 2))
        elif question_type == 'judge':
            questions = Classify.query.filter_by(id=question_classify).first().questions.filter_by(type=4)
        elif question_type == 'fill':
            questions = Classify.query.filter_by(id=question_classify).first().questions.filter_by(type=3)
        elif question_type == 'essay':
            questions = Classify.query.filter_by(id=question_classify).first().questions.filter_by(type=5)
        questions = questions.filter_by(user_id=current_user.id)
        return render_template('admin/problem/question.html',
                               title=gettext('Question Manage'),
                               questions=questions,
                               type=question_type,
                               question_classify=question_classify)
    elif request.method == 'POST':
        # 删除练习题目
        curr_question = Question.query.filter_by(id=request.form['id']).first_or_404()
        db.session.delete(curr_question)
        db.session.commit()
        return jsonify(status="success", question_id=curr_question.id)


@admin.route('/problem/program/<int:question_classify>/', methods=['GET', 'POST'])
@teacher_login
def program_filter_by_classify(question_classify):
    """ 题库中编程题的入口页面 """
    if request.method == 'GET':
        return render_template('admin/problem/program.html', title=gettext('Program question'))
    elif request.method == 'POST':
        # 删除编程题目
        curr_program = Program.query.filter_by(id=request.form['id']).first_or_404()
        for s in curr_program.submit_programs:
            curr_program.submit_programs.remove(s)
            db.session.delete(s)
        db.session.delete(curr_program)
        db.session.commit()
        return unicode(curr_program.id)


@admin.route('/problem/<question_type>/create/', methods=['GET', 'POST'])
@teacher_login
def question_create(question_type):
    if request.method == 'GET':
        question_classify = request.args.get("question_classify", None)
        return render_template('admin/problem/question_detail.html',
                               title=gettext('Edit question'),
                               op='create',
                               classifies=current_user.teacher_classify,
                               mode='practice',
                               type=question_type,
                               question_classify=question_classify)
    elif request.method == 'POST':
        # 添加练习题目
        curr_question = Question(type=request.form['type'], content=request.form['content'],
                                 solution=request.form['solution'], analysis=request.form['analysis'])
        curr_question.teacher = current_user
        classifies = request.form.getlist('classify')
        for x in classifies:
            curr_question.classifies.append(Classify.query.filter_by(id=x).first_or_404())
        db.session.add(curr_question)
        db.session.commit()
        return redirect(url_for('admin.question', question_type=question_type))


@admin.route('/problem/<question_type>/edit/<int:question_id>/', methods=['GET', 'POST'])
@teacher_login
def question_edit(question_type, question_id):
    if request.method == 'GET':
        question_classify = request.args.get("question_classify", None)
        curr_question = Question.query.filter_by(id=question_id).first_or_404()
        curr_classifies = {}
        index = 0
        for c in curr_question.classifies:
            curr_classifies[index] = c.id
            index += 1
        return render_template('admin/problem/question_detail.html',
                               title=gettext('Edit question'),
                               op='edit',
                               question=curr_question,
                               classifies=current_user.teacher_classify,
                               mode='practice',
                               type=question_type,
                               curr_classifies=json.dumps(curr_classifies, ensure_ascii=False),
                               question_classify=question_classify)
    elif request.method == 'POST':
        # 编辑练习题
        curr_question = Question.query.filter_by(id=request.form['id']).first_or_404()
        curr_question.type = request.form['type']
        curr_question.content = request.form['content']
        curr_question.solution = request.form['solution']
        curr_question.analysis = request.form['analysis']
        for x in xrange(len(curr_question.classifies)):
            curr_question.classifies.pop(0)
        classifies = request.form.getlist('classify')
        for x in classifies:
            curr_question.classifies.append(Classify.query.filter_by(id=x).first_or_404())
        db.session.commit()
        return redirect(url_for('admin.question', question_type=question_type))


@admin.route('/paper/<int:paper_id>/<question_type>/create/', methods=['GET', 'POST'])
@teacher_login
def paper_question_create(paper_id, question_type):
    if request.method == 'GET':
        curr_paper = Paper.query.filter_by(id=paper_id).first_or_404()
        return render_template('admin/problem/question_detail.html',
                               title=gettext('Create question'),
                               op='create',
                               classifies=current_user.teacher_classify,
                               mode='paper',
                               curr_paper=curr_paper,
                               type=question_type)
    elif request.method == 'POST':
        # 添加试卷题目
        curr_paper = Paper.query.filter_by(id=paper_id).first_or_404()
        curr_question = Question(type=request.form['type'], content=request.form['content'],
                                 solution=request.form['solution'], analysis=request.form['analysis'])
        curr_question.teacher = current_user
        aux = PaperQuestion(point=request.form['point'])
        aux.questions = curr_question
        db.session.add(aux)
        curr_paper.questions.append(aux)
        classifies = request.form.getlist('classify')
        for x in classifies:
            curr_question.classifies.append(Classify.query.filter_by(id=x).first_or_404())
        db.session.add(curr_question)
        db.session.commit()
        return redirect(url_for('admin.paper_edit', course_id=curr_paper.course.id, paper_id=curr_paper.id))


@admin.route('/paper/<int:paper_id>/<question_type>/edit/<int:question_id>/', methods=['GET', 'POST'])
@teacher_login
def paper_question_edit(paper_id, question_type, question_id):
    if request.method == 'GET':
        curr_paper = Paper.query.filter_by(id=paper_id).first_or_404()
        curr_question = curr_paper.questions.filter_by(question_id=question_id).first_or_404()
        curr_classifies = {}
        index = 0
        for c in curr_question.questions.classifies:
            curr_classifies[index] = c.id
            index += 1
        return render_template('admin/problem/question_detail.html',
                               title=gettext('Edit question'),
                               op='edit',
                               question=curr_question.questions,
                               classifies=current_user.teacher_classify,
                               mode='paper',
                               curr_paper=curr_paper,
                               point=curr_question.point,
                               type=question_type,
                               curr_classifies=json.dumps(curr_classifies, ensure_ascii=False))
    elif request.method == 'POST':
        # 编辑试卷题目
        curr_paper = Paper.query.filter_by(id=request.form['pid']).first_or_404()
        aux = curr_paper.questions.filter_by(question_id=request.form['id']).first_or_404()
        aux.point = request.form['point']
        curr_question = aux.questions
        curr_question.type = request.form['type']
        curr_question.content = request.form['content']
        curr_question.solution = request.form['solution']
        curr_question.analysis = request.form['analysis']
        for x in xrange(len(curr_question.classifies)):
            curr_question.classifies.pop(0)
        classifies = request.form.getlist('classify')
        for x in classifies:
            curr_question.classifies.append(Classify.query.filter_by(id=x).first_or_404())
        db.session.commit()
        return redirect(url_for('admin.paper_edit', course_id=curr_paper.course.id, paper_id=curr_paper.id))


@admin.route('/problem/program/', methods=['GET', 'POST'])
@teacher_login
def program():
    """ 题库中编程题的入口页面 """
    if request.method == 'GET':
        return render_template('admin/problem/program.html', title=gettext('Program question'))
    elif request.method == 'POST':
        # 删除编程题目
        curr_program = Program.query.filter_by(id=request.form['id']).first_or_404()
        if request.form['op'] == 'before-del':
            has_homework = 0
            if len(curr_program.homework) > 0:
                has_homework = 1
            return jsonify(status="success", has=has_homework)
        else:
            for s in curr_program.submit_programs:
                curr_program.submit_programs.remove(s)
                db.session.delete(s)
            for h in curr_program.homework:
                h.program.remove(curr_program)
            db.session.delete(curr_program)
            db.session.commit()
        return unicode(curr_program.id)


@admin.route('/problem/program/create/', methods=['GET', 'POST'])
@teacher_login
def program_create():
    """ 在题库添加编程题 """
    if request.method == 'GET':
        return render_template('admin/problem/program_detail.html',
                               title=gettext('Create question'),
                               op='create')
    elif request.method == 'POST':
        # 添加编程题
        curr_program = Program(title=request.form['title'],
                               detail=request.form['content'],
                               default_code=request.form['default-code'])
        curr_program.teacher = current_user
        db.session.add(curr_program)
        db.session.commit()

        return redirect(url_for('admin.program', tag2="lab-2"))


@admin.route('/problem/program/edit/', methods=['GET', 'POST'])
@teacher_login
def program_edit():
    """ 题库中编程题目的编辑页面 """
    if request.method == 'GET':
        curr_program = Program.query.filter_by(id=request.args['id']).first_or_404()
        return render_template('admin/problem/program_detail.html',
                               title=gettext('Edit question'),
                               op='edit',
                               program_problem=curr_program)
    elif request.method == 'POST':
        # 编辑编程题
        curr_program = Program.query.filter_by(id=request.form['id']).first_or_404()
        curr_program.title = request.form['title']
        curr_program.detail = request.form['content']
        curr_program.default_code = request.form['default-code']
        db.session.commit()
        return redirect(url_for('admin.program'))


@admin.route('/problem/program/evaluate/', methods=['GET', 'POST'])
@teacher_login
def program_evaluate():
    """ 题库中编程题的评测设置 """
    if request.method == 'GET':
        curr_program = Program.query.filter_by(id=request.args['id']).first_or_404()
        return render_template('admin/problem/program_evaluate_edit.html',
                               program=curr_program,
                               title=u'评测设置')
    elif request.method == 'POST':
        curr_program = Program.query.filter_by(id=request.form['id']).first_or_404()
        if request.form['can_evaluate'] == 'on':
            curr_program.can_evaluate = True
        elif request.form['can_evaluate'] == 'off':
            curr_program.can_evaluate = False
        curr_program.serial_code = request.form['serial-code']
        curr_program.ref_code = request.form['ref-code']
        curr_program.null_code = request.form['null-code']
        curr_program.pi_code = request.form['pi-code']
        db.session.commit()

        if curr_program.can_evaluate:
            input_filename_1 = "hello.cpp"
            input_filename_2 = "ref.cpp"
            input_filename_3 = "serial.cpp"
            input_PI = "PI.cpp"

            output_filename_1 = "hello"
            output_filename_2 = "ref"
            output_filename_3 = "serial"
            output_PI = "PI"

            input_text_1 = curr_program.null_code
            input_text_2 = curr_program.ref_code
            input_text_3 = curr_program.serial_code
            input_text_PI = curr_program.pi_code

            input_files = [input_filename_1, input_filename_2, input_filename_3, input_PI]
            output_files = [output_filename_1, output_filename_2, output_filename_3, output_PI]
            input_data = [input_text_1, input_text_2, input_text_3, input_text_PI]

            # 使用多线程来异步调用init_evaluate_program(str(curr_program.id), input_files, input_data, output_files)
            thr = Thread(target=init_evaluate_program, args=[str(curr_program.id), input_files, input_data, output_files])
            thr.start()

        return redirect(url_for('admin.program'))


@admin.route('/lab/', methods=['GET', 'POST'])
@teacher_login
def lab():
    if request.method == 'GET':
        return render_template('admin/lab/index.html',
                               title=gettext('Lab Manage'),
                               type='code_lab')
    elif request.method == 'POST':
        if request.form['op'] == 'create':
            curr_knowledge = Knowledge(title=request.form['title'], content=request.form['content'])
            curr_knowledge.teacher = current_user
            db.session.add(curr_knowledge)
            db.session.commit()
            if request.files['cover']:
                curr_knowledge.cover_url = os.path.join('upload/lab/', "cover_%d.png" % curr_knowledge.id)
                filename = "cover_%d.png" % curr_knowledge.id
                cover_path = os.path.join(current_app.config['LAB_COVER_FOLDER'], filename)
                upload_img(request.files['cover'], 171, 304, cover_path)
                db.session.commit()
            else:
                curr_knowledge.cover_url = "upload/lab/default.jpg"
                db.session.commit()
            return jsonify(status='success')
        elif request.form['op'] == 'edit':
            curr_knowledge = Knowledge.query.filter_by(id=request.form['knowledge_id']).first_or_404()
            curr_knowledge.title = request.form['title']
            curr_knowledge.content = request.form['content']
            if request.files['cover']:
                curr_knowledge.cover_url = os.path.join('upload/lab/', "cover_%d.png" % curr_knowledge.id)
                filename = "cover_%d.png" % curr_knowledge.id
                cover_path = os.path.join(current_app.config['LAB_COVER_FOLDER'], filename)
                status = upload_img(request.files['cover'], 171, 304, cover_path)
            db.session.commit()
            return jsonify(status='success')
        elif request.form['op'] == 'del':
            curr_knowledge = Knowledge.query.filter_by(id=request.form['knowledge_id']).first_or_404()
            for challenge in curr_knowledge.challenges:
                db.session.delete(challenge)
            db.session.delete(curr_knowledge)
            db.session.commit()
            return jsonify(status='success')


@admin.route('/lab/<int:knowledge_id>/', methods=['GET', 'POST'])
@teacher_login
def lab_view(knowledge_id):
    if request.method == 'GET':
        curr_knowledge = Knowledge.query.filter_by(id=knowledge_id).first_or_404()
        return render_template('admin/lab/knowledge.html',
                               title=gettext('Lab tasks'),
                               knowledge=curr_knowledge)
    elif request.method == 'POST':
        # 删除任务以及调整顺序
        if request.form['op'] == 'del':
            curr_challenge = Challenge.query.filter_by(id=request.form['challenge_id']).first_or_404()
            curr_knowledge = Knowledge.query.filter_by(id=knowledge_id).first_or_404()
            curr_knowledge.challenges.remove(curr_challenge)
            for x in curr_knowledge.challenges:
                if x.knowledgeNum >= curr_challenge.knowledgeNum:
                    x.knowledgeNum -= 1
            db.session.delete(curr_challenge)
            db.session.commit()
            return jsonify(status='success')
        elif request.form['op'] == 'seq':
            curr_knowledge = Knowledge.query.filter_by(id=knowledge_id).first_or_404()
            seq = json.loads(request.form['seq'])
            for x in curr_knowledge.challenges:
                x.knowledgeNum = seq[str(x.id)]
            db.session.commit()
            return jsonify(status='success')


@admin.route('/lab/<int:knowledge_id>/create/', methods=['GET', 'POST'])
@teacher_login
def lab_create(knowledge_id):
    if request.method == 'GET':
        curr_knowledge = Knowledge.query.filter_by(id=knowledge_id).first_or_404()
        materials = []
        for c in current_user.teacher_courses:
            for l in c.lessons:
                for m in l.materials:
                    materials.append(m)
        return render_template('admin/lab/knowledge_detail.html',
                               title=gettext('Lab Create'),
                               op='create',
                               knowledge=curr_knowledge,
                               materials=materials)
    elif request.method == 'POST':
        # 创建任务
        curr_knowledge = Knowledge.query.filter_by(id=knowledge_id).first_or_404()
        curr_challenge = Challenge(title=request.form['title'], content=request.form['content'],
                                   source_code=request.form['source_code'], default_code=request.form['default_code'],
                                   language=request.form['language'], task_number=request.form['task_number'],
                                   cpu_number_per_task=request.form['cpu_number_per_task'],
                                   node_number=request.form['node_number'])

        curr_challenge.knowledgeNum = curr_knowledge.challenges.count() + 1
        db.session.add(curr_challenge)
        curr_knowledge.challenges.append(curr_challenge)

        if int(request.form['material_id']) != -1:
            curr_material = Material.query.filter_by(id=request.form['material_id']).first_or_404()
            curr_material.challenges.append(curr_challenge)

        db.session.commit()
        return jsonify(status='success', challenge_id=curr_challenge.id)


@admin.route('/lab/<int:knowledge_id>/edit/<int:challenge_id>/', methods=['GET', 'POST'])
@teacher_login
def lab_edit(knowledge_id, challenge_id):
    if request.method == 'GET':
        curr_knowledge = Knowledge.query.filter_by(id=knowledge_id).first_or_404()
        curr_challenge = Challenge.query.filter_by(id=challenge_id).first_or_404()
        materials = []
        for c in current_user.teacher_courses:
            for l in c.lessons:
                for m in l.materials:
                    materials.append(m)
        print curr_challenge.language, curr_challenge.task_number, curr_challenge.cpu_number_per_task, curr_challenge.node_number
        return render_template('admin/lab/knowledge_detail.html',
                               title=gettext('Lab Edit'),
                               op='edit',
                               knowledge=curr_knowledge,
                               challenge=curr_challenge,
                               materials=materials)
    elif request.method == 'POST':
        if 'op' in request.form:
            if request.form['op'] == 'get_code':
                curr_challenge = Challenge.query.filter_by(id=challenge_id).first_or_404()
                return jsonify(status='success', default_code=curr_challenge.default_code,
                               source_code=curr_challenge.source_code)
        else:
            # 编辑任务
            curr_challenge = Challenge.query.filter_by(id=challenge_id).first_or_404()
            curr_challenge.title = request.form['title']
            curr_challenge.content = request.form['content']
            curr_challenge.source_code = request.form['source_code']
            curr_challenge.default_code = request.form['default_code']
            curr_challenge.language = request.form['language']
            curr_challenge.task_number = request.form['task_number']
            curr_challenge.cpu_number_per_task = request.form['cpu_number_per_task']
            curr_challenge.node_number = request.form['node_number']

            if int(request.form['material_id']) != -1:
                curr_challenge.material.challenges.remove(curr_challenge)
                curr_material = Material.query.filter_by(id=request.form['material_id']).first_or_404()
                curr_material.challenges.append(curr_challenge)

            db.session.commit()
            return jsonify(status="success")


@admin.route('/vnc_lab/', methods=['GET', 'POST'])
@teacher_login
def vnc_lab():
    if request.method == 'GET':
        return render_template('admin/lab/vnc_index.html', title=gettext('VNC Lab Manage'), type='vnc_lab')
    elif request.method == 'POST':
        op = request.form.get('op', None)
        if op is not None:
            if op == 'del':
                vnc_knowledge_id = request.form.get('vnc_knowledge_id', None)
                if vnc_knowledge_id is not None:
                    vnc_knowledge_to_del = current_user.teacher_vnc_knowledge.filter_by(id=vnc_knowledge_id).first()
                    if vnc_knowledge_to_del is not None:
                        db.session.delete(vnc_knowledge_to_del)
                        db.session.commit()
                        return jsonify(status='success')
                    else:
                        return jsonify(status='fail')
                else:
                    return jsonify(status='fail')
            if op == 'edit':
                title = request.form.get('title', None)
                about = request.form.get('about', None)
                vnc_knowledge_id = request.form.get('vnc_knowledge_id', None)
                cover = request.files['cover']

                if title is not None and about is not None and vnc_knowledge_id is not None:
                    vnc_knowledge_to_edit = current_user.teacher_vnc_knowledge.filter_by(id=vnc_knowledge_id).first()
                    if vnc_knowledge_to_edit is not None:
                        vnc_knowledge_to_edit.title = title
                        vnc_knowledge_to_edit.about = about
                    else:
                        return jsonify(status='fail')
                    if cover:
                        vnc_knowledge_to_edit.cover_url = os.path.join('upload/vnc_lab/', "cover_%d.png" % vnc_knowledge_to_edit.id)
                        filename = "cover_%d.png" % vnc_knowledge_to_edit.id
                        cover_path = os.path.join(current_app.config['VNC_LAB_COVER_FOLDER'], filename)
                        upload_img(cover, 171, 304, cover_path)
                    db.session.commit()
                    return jsonify(status='success')
                else:
                    return jsonify(status='fail')
            if op == 'create':
                title = request.form.get('title', None)
                about = request.form.get('about', None)
                vnc_knowledge_id = request.form.get('vnc_knowledge_id', None)
                cover = request.files['cover']
                if title is not None and about is not None and vnc_knowledge_id is not None:
                    vnc_knowledge_to_create = VNCKnowledge(title=title, about=about)
                    vnc_knowledge_to_create.teacher = current_user
                    db.session.add(vnc_knowledge_to_create)
                    db.session.commit()

                    if cover:
                        vnc_knowledge_to_create.cover_url = os.path.join('upload/vnc_lab/', "cover_%d.png" % vnc_knowledge_to_create.id)
                        filename = "cover_%d.png" % vnc_knowledge_to_create.id
                        cover_path = os.path.join(current_app.config['VNC_LAB_COVER_FOLDER'], filename)
                        upload_img(cover, 171, 304, cover_path)
                        db.session.commit()
                    else:
                        vnc_knowledge_to_create.cover_url = "upload/vnc_lab/default.jpg"
                        db.session.commit()
                    return jsonify(status='success')

                else:
                    return jsonify(status='fail')
        else:
            return jsonify(status='fail')


@admin.route('/vnc_lab/<int:vnc_knowledge_id>/', methods=['GET', 'POST'])
@teacher_login
def vnc_lab_view(vnc_knowledge_id):
    if request.method == 'GET':
        cur_vnc_knowledge = current_user.teacher_vnc_knowledge.filter_by(id=vnc_knowledge_id).first_or_404()
        return render_template('admin/lab/vnc_tasks_list.html', cur_vnc_knowledge=cur_vnc_knowledge, title=gettext('VNC Lab View'))
    elif request.method == 'POST':
        op = request.form.get('op', None)
        if op is not None:
            if op == 'del':
                vnc_task_id = request.form.get('vnc_task_id', None)
                if vnc_task_id is not None:
                    cur_vnc_knowledge = current_user.teacher_vnc_knowledge.filter_by(id=vnc_knowledge_id).first()
                    if cur_vnc_knowledge is not None:
                        vnc_task_to_del = cur_vnc_knowledge.vnc_tasks.filter_by(id=vnc_task_id).first()
                        if vnc_task_to_del is not None:
                            for task in cur_vnc_knowledge.vnc_tasks:
                                if task.vnc_task_num > vnc_task_to_del.vnc_task_num:
                                    task.vnc_task_num -= 1
                            for progress in cur_vnc_knowledge.vnc_progresses:
                                if progress.have_done > vnc_task_to_del.vnc_task_num:
                                    progress.have_done -= 1
                            db.session.delete(vnc_task_to_del)
                            db.session.commit()
                            return jsonify(status='success')
                        else:
                            return jsonify(status='fail')
                    else:
                        return jsonify(status='fail')
                else:
                    return jsonify(status='fail')
            elif op == 'seq':
                cur_vnc_knowledge = current_user.teacher_vnc_knowledge.filter_by(id=vnc_knowledge_id).first()
                if cur_vnc_knowledge is not None:
                    seq = json.loads(request.form['seq'])
                    for task in cur_vnc_knowledge.vnc_tasks:
                        task.vnc_task_num = seq[str(task.id)]
                    db.session.commit()
                    return jsonify(status='success')
                else:
                    return jsonify(status='fail')
        else:
            return jsonify(status='fail')


@admin.route('/vnc_lab/<int:vnc_knowledge_id>/create/', methods=['GET', 'POST'])
@teacher_login
def vnc_lab_create(vnc_knowledge_id):
    if request.method == 'GET':
        return render_template('admin/lab/vnc_tasks_detail.html', op='create', vnc_knowledge_id=vnc_knowledge_id, title=gettext('VNC Lab Create'))
    elif request.method == 'POST':
        title = request.form.get('title', None)
        content = request.form.get('content', None)
        if title is not None and content is not None:
            cur_vnc_knowledge = current_user.teacher_vnc_knowledge.filter_by(id=vnc_knowledge_id).first()
            if cur_vnc_knowledge is not None:
                vnc_task_to_create = VNCTask(title=title, content=content)
                vnc_task_to_create.vnc_task_num = cur_vnc_knowledge.vnc_tasks.count() + 1
                vnc_task_to_create.vnc_knowledge = cur_vnc_knowledge
                db.session.add(vnc_task_to_create)
                db.session.commit()
                return jsonify(status='success')
            else:
                return jsonify(status='fail')
        else:
            return jsonify(status='fail')


@admin.route('/vnc_lab/<int:vnc_knowledge_id>/edit/<int:vnc_task_id>/', methods=['GET', 'POST'])
@teacher_login
def vnc_lab_edit(vnc_knowledge_id, vnc_task_id):
    if request.method == 'GET':
        cur_vnc_knowledge = current_user.teacher_vnc_knowledge.filter_by(id=vnc_knowledge_id).first_or_404()
        cur_vnc_task = cur_vnc_knowledge.vnc_tasks.filter_by(id=vnc_task_id).first_or_404()
        return render_template('admin/lab/vnc_tasks_detail.html', op='edit', title=gettext('VNC Lab Edit'),
                               cur_vnc_task=cur_vnc_task, vnc_knowledge_id=vnc_knowledge_id)
    elif request.method == 'POST':
        title = request.form.get('title', None)
        content = request.form.get('content', None)
        if title is not None and content is not None:
            cur_vnc_knowledge = current_user.teacher_vnc_knowledge.filter_by(id=vnc_knowledge_id).first()
            if cur_vnc_knowledge is not None:
                cur_vnc_task = cur_vnc_knowledge.vnc_tasks.filter_by(id=vnc_task_id).first()
                if cur_vnc_task is not None:
                    cur_vnc_task.title = title
                    cur_vnc_task.content = content
                    db.session.commit()
                    return jsonify(status='success')
                else:
                    return jsonify(status='fail')
            else:
                return jsonify(status='fail')
        else:
            return jsonify(status='fail')


@admin.route('/download/paper/<int:paper_id>/')
@teacher_login
def paper_pdf(paper_id):
    path = get_paper_pdf(paper_id)
    response = make_response(send_file(path))
    response.headers["Content-Disposition"] = "attachment; filename=%s;" % path[path.rfind('/')+1:]
    return response


@admin.route("/classifies/", methods=['GET', 'POST'])
@teacher_login
def classify():
    if request.method == 'GET':
        classifies = current_user.teacher_classify
        return render_template('admin/classify/index.html',
                               title=gettext("Classify Admin"),
                               classifies=classifies)
    elif request.method == 'POST':
        if request.form['op'] == 'create':
            new_classify = Classify(name=request.form['cname'])
            new_classify.teacher = current_user
            db.session.add(new_classify)
            db.session.commit()
            return jsonify(status='success')
        elif request.form['op'] == 'edit':
            cur_classify = Classify.query.filter_by(id=request.form['cid']).first_or_404()
            cur_classify.name = request.form['cname']
            db.session.commit()
            return jsonify(status='success')
        elif request.form['op'] == 'del':
            cur_classify = Classify.query.filter_by(id=request.form['cid']).first_or_404()
            db.session.delete(cur_classify)
            db.session.commit()
            return jsonify(status='success')
