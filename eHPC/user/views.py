#! /usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: xuezaigds@gmail.com
# @Last Modified time: 2017-04-14 21:25:59
from flask import render_template, redirect, request, url_for, current_app, abort, jsonify, session
from flask_login import login_user, logout_user, current_user, login_required
from flask_babel import gettext
from flask_paginate import Pagination
import re
import os
from PIL import Image
from datetime import datetime, timedelta

from eHPC.util.captcha import verify_captcha
from . import user
from ..models import User, Statistic
from ..util.email import send_email
from .. import db
from ..util.file_manage import get_file_type
from ..user.authorize import system_login
from ..util.notifications import read_message
import json
import threading
from ..admin.utils import save_address

alphanumeric = re.compile(r'^[0-9a-zA-Z\_]*$')
email_address = re.compile(r'[a-zA-z0-9]+\@[a-zA-Z0-9]+\.+[a-zA-Z]')


@user.route('/signin/', methods=['GET', 'POST'])
def signin():
    if request.method == 'GET':
        # if current_user.is_authenticated:
        #     return redirect(request.args.get('next') or url_for("main.index"))
        return render_template('user/signin.html',
                               title=gettext('User Sign In'),
                               form=None)
    elif request.method == 'POST':
        _form = request.form
        u = User.query.filter_by(email=_form['email']).first()

        if u is None:
            message = gettext('Invalid username or password.')
            return render_template('user/signin.html', title=gettext('User Sign In'), form=_form, message=message)

        if not u.is_verify_email:
            return redirect(url_for('user.verify_email', user_id=u.id))

        session.permanent = True
        current_app.permanent_session_lifetime = timedelta(days=1)
        next_url = request.args.get('next')
        if next_url:
            next_url = None if request.args.get('next')[:6] == '/user/' else request.args.get('next')

        resp = _form.get('luotest_response')
        if not verify_captcha(resp):
            message = u'人机识别验证失败'
            return render_template('user/signin.html', title=gettext('User Sign In'),
                                   form=_form, message=message)

        if u and u.verify_password(_form['password']):
            login_user(u)
            u.last_login = datetime.now()
            db.session.commit()

            if request.headers.getlist("X-Forwarded-For"):
                ip = request.headers.getlist("X-Forwarded-For")[0]
            else:
                ip = request.remote_addr

            save_address(ip)

            if u.permissions == 2 and (next_url == '/' or next_url is None):
                return redirect(url_for('admin.teacher'))

            return redirect(next_url or url_for('main.index'))
        else:
            message = gettext('Invalid username or password.')
            return render_template('user/signin.html', title=gettext('User Sign In'), form=_form, message=message)


@user.route('/signout/')
@login_required
def signout():
    logout_user()
    return redirect(request.args.get('next') or request.referrer or url_for('main.index'))


# 注册邮箱合法性验证
@user.route('/register/valid')
def reg_valid():
    mail = request.args.get('mail')
    status = 'success'
    if User.query.filter_by(email=mail).first():
        status = 'fail'
    return jsonify(status=status)


@user.route('/register/', methods=['GET', 'POST'])
def reg():
    if request.method == 'GET':
        return render_template('user/reg.html',
                               title=gettext('Register Account'),
                               form=None)
    elif request.method == 'POST':
        _form = request.form
        resp = _form.get('luotest_response')
        if not verify_captcha(resp):
            message_captcha = u'人机识别验证失败'
            return render_template('user/reg.html', title=gettext('Register Account'),
                                   data=_form, message_captcha=message_captcha)

        email = _form['email']
        password = _form['password']
        password2 = _form['password2']

        username = _form['username']
        name = _form.get('name')
        phone = _form.get('phone')
        university = _form.get('university')

        message_e, message_u, message_p = "", "", ""
        # Check username is valid or not.
        if User.query.filter_by(username=_form['username']).first():
            message_u = gettext('Username already exists.')

        # Check email is valid or not.
        if User.query.filter_by(email=email).first():
            message_e = gettext('Email already exists.')

        if password != password2:
            message_e = u'两次输入密码不一致'

        data = None
        if message_u or message_e or message_e:
            data = _form

        if message_u or message_p or message_e:
            return render_template("user/reg.html", form=_form,
                                   title=gettext('Register Account'),
                                   message_u=message_u,
                                   message_p=message_p,
                                   message_e=message_e,
                                   data=data)

        # A valid register info, save the info into db.
        else:
            reg_user = User()
            reg_user.email = email
            reg_user.password = password
            reg_user.username = username
            reg_user.name = name
            reg_user.phone = phone
            reg_user.university = university
            reg_user.avatar_url = 'none.jpg'

            # 如果是学生用户
            if _form.get('type') == '0':
                gender = _form.get('gender', 1)
                student_id = _form.get('student_id', 0)
                student_type = _form.get('student_type', 0)
                reg_user.gender = gender
                reg_user.student_id = student_id
                reg_user.student_type = student_type

            db.session.add(reg_user)
            db.session.commit()

            if request.headers.getlist("X-Forwarded-For"):
                ip = request.headers.getlist("X-Forwarded-For")[0]
            else:
                ip = request.remote_addr

            if _form.get('type') == '1':
                send_email(ip, current_app.config['MAIL_ADMIN_ADDR'], u'教师用户注册提醒', 'user/reg_teacher_email', user=reg_user)
                return render_template('user/teacher_reg_note.html')

            token = reg_user.generate_email_token()
            send_email(ip, reg_user.email, u'EasyHPC邮箱验证', 'user/verify_email', user=reg_user, token=token)
            reg_user.verify_email_time = datetime.now()
            db.session.commit()

            return redirect(url_for('user.verify_email', user_id=reg_user.id))


@user.route('/<int:uid>/')
def view(uid):
    cur_user = User.query.filter_by(id=uid).first_or_404()
    return render_template('user/detail.html',
                           title=gettext('Personal Page'),
                           user=cur_user)


@user.route('/password/reset/', methods=['GET', 'POST'])
def password_reset_request():
    if request.method == 'GET':
        return render_template('user/passwd_reset.html', form=None)
    elif request.method == 'POST':
        _form = request.form
        resp = _form.get('luotest_response')
        if not verify_captcha(resp):
            return render_template('user/passwd_reset.html', message_captcha=u'人机识别验证失败')

        email_addr = _form["email"]
        u = User.query.filter_by(email=email_addr).first()
        message_email = ''
        if not email_addr:
            message_email = gettext("The email can not be empty")
        elif not u:
            message_email = gettext("The email has not be registered")

        if message_email:
            return render_template('user/passwd_reset.html', message_email=message_email)
        else:
            token = u.generate_reset_token()
            # Clear the token status to "True".
            u.is_password_reset_link_valid = True
            db.session.commit()
            if request.headers.getlist("X-Forwarded-For"):
                ip = request.headers.getlist("X-Forwarded-For")[0]
            else:
                ip = request.remote_addr

            send_email(ip, u.email, 'Reset Your Password',
                       'user/passwd_reset_email',
                       user=u, token=token)

            return render_template('user/passwd_reset_sent.html')


@user.route('/password/reset/<token>/', methods=['GET', 'POST'])
def password_reset(token):
    if request.method == "GET":
        u = User.verify_token(token)
        if u and u.is_password_reset_link_valid:
            return render_template('user/passwd_reset_confirm.html', form=None)
        else:
            return render_template('user/passwd_reset_done.html', message='Failed')
    elif request.method == 'POST':
        _form = request.form
        new_password = _form['password']
        new_password_2 = _form['password2']

        message_p = ""
        if new_password != new_password_2:
            message_p = gettext("Passwords don't match.")
        elif new_password_2 == "" or new_password == "":
            message_p = gettext("Passwords can not be empty.")

        if message_p:
            return render_template('user/passwd_reset_confirm.html', message_p=message_p)
        else:
            # Get the token without input the email address.
            u = User.verify_token(token)
            if u and u.is_password_reset_link_valid:
                u.password = new_password
                u.is_password_reset_link_valid = False
                db.session.commit()
                reset_result = "Successful"
            else:
                reset_result = "Failed"

            return render_template('user/passwd_reset_done.html', message=reset_result)


@user.route('/setting/')
@login_required
def setting():
    if request.method == 'GET':
        return render_template('user/setting.html',
                               title=gettext("Setting"),
                               form=None)


@user.route('/setting/info/', methods=['GET', 'POST'])
@login_required
def setting_info():
    if request.method == 'GET':
        return jsonify(content=render_template('user/ajax_setting_info.html', form=None))

    elif request.method == 'POST':
        _form = request.form
        email_addr = _form["email"]
        web_addr = _form["website"]

        message_email = ""

        # TODO
        # Change the user's email need to verify the old_email addr's ownership
        if message_email:
            return jsonify(content=render_template("user/ajax_setting_info.html",
                                                   message_email=message_email))
        else:
            current_user.website = web_addr
            current_user.email = email_addr
            current_user.name = _form['name']
            current_user.gender = _form['gender']
            current_user.phone = _form['phone']
            current_user.university = _form['university']
            current_user.student_id = _form['student_id']

            db.session.commit()
            message_success = gettext('Update info done!')
            return jsonify(content=render_template('user/ajax_setting_info.html',
                                                   message_success=message_success))


@user.route("/setting/avatar/", methods=['GET', 'POST'])
@login_required
def setting_avatar():
    if request.method == 'GET':
        return jsonify(content=render_template('user/ajax_setting_avatar.html',
                                               form=None))

    elif request.method == 'POST':
        _file = request.files['file']

        avatar_folder = current_app.config['AVATAR_FOLDER']
        file_type = get_file_type(_file.mimetype)
        if _file and '.' in _file.filename and file_type == "img":
            im = Image.open(_file)
            im.thumbnail((128, 128), Image.ANTIALIAS)

            image_path = os.path.join(avatar_folder, "%d.png" % current_user.id)
            im.save(image_path, 'PNG')
            unique_mark = os.stat(image_path).st_mtime
            current_user.avatar_url = '%d.png?t=%s' % (current_user.id, unique_mark)

            db.session.commit()
            message_success = gettext('Update avatar done!')
            return jsonify(content=render_template('user/ajax_setting_avatar.html',
                                                   message_success=message_success))
        else:
            message_fail = gettext("Invalid file")
            return jsonify(content=render_template('user/ajax_setting_avatar.html',
                                                   message_fail=message_fail))


@user.route("/setting/password/", methods=['GET', 'POST'])
@login_required
def setting_password():
    if request.method == 'GET':
        return jsonify(content=render_template('user/ajax_setting_passwd.html', form=None))

    elif request.method == 'POST':
        _form = request.form
        cur_password = _form['old-password']
        new_password = _form['password1']
        new_password_2 = _form['password2']

        message_cur, message_new = "", ""
        if not current_user.verify_password(cur_password):
            message_cur = "The old password is not correct."

        if message_cur or message_new:
            return jsonify(content=render_template('user/ajax_setting_passwd.html', form=_form,
                                                   message_cur=message_cur,
                                                   message_new=message_new))
        else:
            current_user.password = new_password
            db.session.commit()
            message_success = gettext("Update password done!")
            return jsonify(content=render_template('user/ajax_setting_passwd.html',
                                                   message_success=message_success))


@user.route('/notifications/', methods=['GET', 'POST'])
@login_required
def notifications():
    if request.method == 'GET':
        return render_template('user/notifications.html',
                               not_read_count=len(current_user.note_info.filter_by(is_read=False).all()),
                               received_count=len(current_user.note_info.all()),
                               sent_count=len(current_user.notifications_sent.all()))

    elif request.method == 'POST':
        note_type = request.form.get("type", None)

        if note_type is None:
            return jsonify(status='fail')

        if note_type == 'not-read':
            not_read = [{'id': r.id,
                         'event_name': r.notification.event_name,
                         'create_time': str(r.notification.create_time),
                         'sender': r.notification.sender.name,
                         'event_content': r.notification.event_content} for r in current_user.note_info.filter_by(is_read=False).all()]
            return jsonify(status='success', note=not_read)
        elif note_type == 'received':
            received = [{'id': r.id,
                         'event_name': r.notification.event_name,
                         'create_time': str(r.notification.create_time),
                         'sender': r.notification.sender.name,
                         'event_content': r.notification.event_content,
                         'is_read': r.is_read} for r in current_user.note_info.all()]
            return jsonify(status='success', note=received)


@user.route('/notifications/read/', methods=['POST'])
@login_required
def notification_read():
    op = request.form.get('op')

    if op == 'read-one-message':
        note_info_id = request.form.get('note_info_id')
        try:
            note_info_id = int(note_info_id)
        except ValueError:
            return jsonify(status='fail')
        status, note_info = read_message(note_info_id)
        if not status:
            return jsonify(status='fail')
        return jsonify(status='success')
    elif op == 'read-all':
        not_read = current_user.note_info.filter_by(is_read=False).all()
        for r in not_read:
            read_message(r.id)
        return jsonify(status='success')


@user.route('/statistics/', methods=['POST', 'GET'])
@login_required
def statistics():
    if request.method == 'GET':
        return render_template('user/statistics.html',
                               statistics=current_user.statistics,
                               Statistic=Statistic)
    elif request.method == 'POST':
        action_code = request.form.get('action_code')
        try:
            action_code = int(action_code)
        except ValueError:
            return jsonify(status='fail')

        if action_code == Statistic.ACTION_COURSE_ATTEND_QUIZ:
            op = request.form.get('op')
            course_id = request.form.get('course_id')

            if not (op and course_id):
                return jsonify(status='fail')
            try:
                course_id = int(course_id)
            except ValueError:
                return jsonify(status='fail')

            if op == 'percentage':
                all_statistics = Statistic.query.filter_by(action=action_code).\
                    filter(Statistic.user_id != current_user.id).all()
                status = {}
                for s in all_statistics:
                    if s.user_id not in status.keys():
                        status[s.user_id] = 0

                for s in all_statistics:
                    if json.loads(s.data)['course_id'] == course_id:
                        status[s.user_id] += 1

                my_statistic = current_user.statistics.filter_by(action=action_code).all()
                my_status = 0
                for s in my_statistic:
                    if json.loads(s.data)['course_id'] == course_id:
                        my_status += 1

                count = 0
                for (k,v) in status.items():
                    if my_status > v:
                        count += 1

                return jsonify(status='success',
                               data=int(round(1.0 * count / (len(status) + 1), 2) * 100),
                               attend_times=my_status)
        elif action_code == Statistic.ACTION_COURSE_SUBMIT_QUIZ_ANSWER:
            op = request.form.get('op')
            course_id = request.form.get('course_id')

            if not (op and course_id):
                return jsonify(status='fail')
            try:
                course_id = int(course_id)
            except ValueError:
                return jsonify(status='fail')

            if op == 'percentage':
                my_statistic = current_user.statistics.filter_by(action=action_code).all()
                correct_count, wrong_count, submit_count = 0, 0, 0
                for s in my_statistic:
                    data = json.loads(s.data)
                    if data['course_id'] == course_id:
                        submit_count += 1
                        result = json.loads(data['result'])
                        for (k, v) in result.items():
                            if v == 'T':
                                correct_count += 1
                            elif v == 'F':
                                wrong_count += 1

                if correct_count + wrong_count == 0:
                    accuracy = 0
                else:
                    accuracy = int(round(1.0 * correct_count / (correct_count + wrong_count), 2) * 100)

                all_statistics = Statistic.query.filter_by(action=action_code). \
                    filter(Statistic.user_id != current_user.id).all()
                correct_status, wrong_status = {}, {}

                for s in all_statistics:
                    if s.user_id not in correct_status.keys():
                        correct_status[s.user_id] = 0
                    if s.user_id not in wrong_status.keys():
                        wrong_status[s.user_id] = 0

                for s in all_statistics:
                    data = json.loads(s.data)
                    if data['course_id'] == course_id:
                        result = json.loads(data['result'])
                        for (k, v) in result.items():
                            if v == 'T':
                                correct_status[s.user_id] += 1
                            elif v == 'F':
                                wrong_status[s.user_id] += 1

                count = 0
                for k in correct_status.keys():
                    if correct_status[k] + wrong_status[k] == 0:
                        k_accuracy = 0
                    else:
                        k_accuracy = int(round(1.0 * correct_status[k] / (correct_status[k] + wrong_status[k]), 2) * 100)
                    if accuracy > k_accuracy:
                        count += 1

                return jsonify(status='success',
                               submit_count=submit_count,
                               accuracy=accuracy,
                               data=int(round(1.0 * count / (len(correct_status) + 1), 2) * 100))


@user.route('/statistics/collect/', methods=['POST'])
@login_required
def collect_statistics():
    action_code = request.form.get('action_code')

    try:
        action_code = int(action_code)
    except ValueError:
        return jsonify(status='fail')

    if action_code == Statistic.ACTION_QUESTION_SUBMIT_ANSWER:
        classify_id = request.form.get('classify_id')
        status = request.form.get('status')
        start_time = request.form.get('start_time')
        end_time = request.form.get('end_time')

        if not (classify_id and status and start_time and end_time):
            return jsonify(status='fail')

        try:
            json.loads(status)
            classify_id = int(classify_id)
            start_time = datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
            end_time = datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')

            if (end_time - start_time).seconds < 10:
                return jsonify(status='success')
        except ValueError:
            return jsonify(status='fail')

        db.session.add(Statistic(current_user.id,
                                 Statistic.ACTION_QUESTION_SUBMIT_ANSWER,
                                 json.dumps(dict(classify_id=classify_id,
                                                 status=status,
                                                 start_time=str(start_time),
                                                 end_time=str(end_time)))))
        db.session.commit()
        return jsonify(status='success')
    elif action_code == Statistic.ACTION_COURSE_VISIT_DOCUMENT_OR_VIDEO:
        material_id = request.form.get("material_id")
        start_time = request.form.get('start_time')
        end_time = request.form.get('end_time')

        if not (material_id and start_time and end_time):
            return jsonify(status='fail')

        try:
            material_id = int(material_id)
            start_time = datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
            end_time = datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')

            if (end_time - start_time).seconds < 60:
                return jsonify(status='success')
        except ValueError:
            return jsonify(status='fail')

        db.session.add(Statistic(current_user.id,
                                 Statistic.ACTION_COURSE_VISIT_DOCUMENT_OR_VIDEO,
                                 json.dumps(dict(material_id=material_id,
                                                 start_time=str(start_time),
                                                 end_time=str(end_time)))))
        db.session.commit()
        return jsonify(status='success')
    elif action_code == Statistic.ACTION_COURSE_ATTEND_QUIZ:
        course_id = request.form.get('course_id')
        paper_id = request.form.get('paper_id')
        start_time = request.form.get('start_time')
        end_time = request.form.get('end_time')

        if not (course_id and paper_id and start_time and end_time):
            return jsonify(status='fail')

        try:
            course_id = int(course_id)
            paper_id = int(paper_id)
            start_time = datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
            end_time = datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')

            if (end_time - start_time).seconds < 30:
                return jsonify(status='success')
        except ValueError:
            return jsonify(status='fail')

        db.session.add(Statistic(current_user.id,
                                 Statistic.ACTION_COURSE_ATTEND_QUIZ,
                                 json.dumps(dict(paper_id=paper_id,
                                                 course_id=course_id,
                                                 start_time=str(start_time),
                                                 end_time=str(end_time)))))
        db.session.commit()
        return jsonify(status='success')
    elif action_code == Statistic.ACTION_COURSE_SUBMIT_QUIZ_ANSWER:
        course_id = request.form.get('course_id')
        paper_id = request.form.get('paper_id')
        result = request.form.get('result')
        start_time = request.form.get('start_time')
        end_time = request.form.get('end_time')

        if not (course_id and paper_id and result and start_time and end_time):
            return jsonify(status='fail')

        try:
            json.loads(result)
            course_id = int(course_id)
            paper_id = int(paper_id)
            start_time = datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
            end_time = datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')

            if (end_time - start_time).seconds < 30:
                return jsonify(status='success')
        except ValueError:
            return jsonify(status='fail')

        db.session.add(Statistic(current_user.id,
                                 Statistic.ACTION_COURSE_SUBMIT_QUIZ_ANSWER,
                                 json.dumps(dict(paper_id=paper_id,
                                                 course_id=course_id,
                                                 result=result,
                                                 start_time=str(start_time),
                                                 end_time=str(end_time)))))
        db.session.commit()
        return jsonify(status='success')
    elif action_code == Statistic.ACTION_LAB_PASS_A_PROGRAMING_TASK:
        knowledge_id = request.form.get('kid')
        challenge_id = request.form.get('challenge_id')
        start_time = request.form.get('start_time')
        end_time = request.form.get('end_time')

        if not (knowledge_id and challenge_id and start_time and end_time):
            return jsonify(status='fail')

        try:
            knowledge_id = int(knowledge_id)
            challenge_id = int(challenge_id)
            start_time = datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
            end_time = datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')

            if (end_time - start_time).seconds < 10:
                return jsonify(status='success')
        except ValueError:
            return jsonify(status='fail')

        db.session.add(Statistic(current_user.id,
                                 Statistic.ACTION_LAB_PASS_A_PROGRAMING_TASK,
                                 json.dumps(dict(knowledge_id=knowledge_id,
                                                 challenge_id=challenge_id,
                                                 start_time=str(start_time),
                                                 end_time=str(end_time)))))
        db.session.commit()
        return jsonify(status='success')
    elif action_code == Statistic.ACTION_LAB_PASS_A_CONFIGURATION_TASK:
        vnc_knowledge_id = request.form.get('vnc_knowledge_id')
        vnc_task_id = request.form.get('vnc_task_id')
        start_time = request.form.get('start_time')
        end_time = request.form.get('end_time')

        if not (vnc_knowledge_id and vnc_task_id and start_time and end_time):
            return jsonify(status='fail')

        try:
            vnc_knowledge_id = int(vnc_knowledge_id)
            vnc_task_id = int(vnc_task_id)
            start_time = datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
            end_time = datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')

            if (end_time - start_time).seconds < 10:
                return jsonify(status='success')
        except ValueError:
            return jsonify(status='fail')

        db.session.add(Statistic(current_user.id,
                                 Statistic.ACTION_LAB_PASS_A_CONFIGURATION_TASK,
                                 json.dumps(dict(vnc_knowledge_id=vnc_knowledge_id,
                                                 vnc_task_id=vnc_task_id,
                                                 start_time=str(start_time),
                                                 end_time=str(end_time)))))
        db.session.commit()
        return jsonify(status='success')


@user.route('/verify/<int:user_id>/', methods=['GET', 'POST'])
def verify_email(user_id):
    if request.method == 'GET':
        u = User.query.get(user_id)
        if u.is_verify_email:
            return abort(503)
        return render_template('user/verify.html')

    elif request.method == 'POST':
        u = User.query.get(user_id)
        if u.is_verify_email:
            return abort(503)
        if (datetime.now() - u.verify_email_time).seconds < 10 * 60:
            return jsonify(status='too_frequently')

        if request.headers.getlist("X-Forwarded-For"):
            ip = request.headers.getlist("X-Forwarded-For")[0]
        else:
            ip = request.remote_addr
        token = u.generate_email_token()
        send_email(ip, u.email, u'EasyHPC邮箱验证', 'user/verify_email', user=u, token=token)
        u.verify_email_time = datetime.now()
        db.session.commit()
        return 'success'


@user.route('/verify/email/<token>/')
def verify_email_check(token):
    u = User.verify_email_token(token)
    if u is not None:
        u.is_verify_email = True
        u.verify_email_time = datetime.now()
        db.session.commit()
        login_user(u)
        return redirect(url_for('user.verify_email_done'))
    else:
        return abort(503)


@user.route('/verify/email/done/')
def verify_email_done():
    return render_template('user/verify_done.html')
