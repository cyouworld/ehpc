#! /usr/bin/env python
# -*- coding: utf-8 -*-
from flask import render_template, request, redirect, url_for, abort, jsonify, current_app
from datetime import datetime
from ..user.authorize import system_login
from . import admin
from ..models import User, Classify, Article, Group, Case, CaseVersion, CaseCodeMaterial
from .. import db
from flask_babel import gettext
import os
from ..util.file_manage import upload_img, upload_file, get_file_type, custom_secure_filename
import shutil
from ..util.file_manage import receive_img


@admin.route('/')
@system_login
def index():
    return render_template('admin/system.html',
                           title=gettext("System Admin"),
                           user_cnt=User.query.count(),
                           article_cnt=Article.query.count(),
                           group_cnt=Group.query.count(),
                           case_cnt=Case.query.count())


@admin.route('/users/')
@system_login
def user():
    all_users = User.query.all()
    return render_template('admin/user/index.html', users=all_users,
                           title=gettext("User Admin"))


@admin.route('/user/edit/<int:uid>/', methods=['GET', 'POST'])
@system_login
def user_edit(uid):
    u = User.query.filter_by(id=uid).first_or_404()
    if request.method == "GET":
        return render_template('admin/user/edit.html', user=u)
    elif request.method == "POST":
        u.permissions = request.form["permission"]
        db.session.commit()
        message_success = gettext('Successfully modify permission')
        return render_template('admin/user/edit.html', user=u,
                               message_success=message_success,
                               title=gettext('User Edit'))


@admin.route('/articles/')
@system_login
def article():
    articles = Article.query.all()
    return render_template('admin/article/index.html',
                           title=gettext('Articles Admin'),
                           articles=articles)


@admin.route('/article/create/', methods=['POST', 'GET'])
@system_login
def article_create():
    if request.method == 'GET':
        return render_template('admin/article/create.html', title=gettext('Create Article'))
    if request.method == 'POST':
        title = request.form['title']
        content = request.form['content']
        new_article = Article(title=title, content=content)
        db.session.add(new_article)
        db.session.commit()
        return redirect(url_for('admin.article'))


@admin.route('/article/<int:aid>/edit/', methods=['POST', 'GET'])
@system_login
def article_edit(aid):
    cur_article = Article.query.filter_by(id=aid).first_or_404()
    if request.method == "GET":
        return render_template('admin/article/edit.html',
                               title=cur_article.title,
                               article=cur_article)
    elif request.method == "POST":
        title = request.form['title']
        content = request.form['content']
        cur_article.title = title
        cur_article.content = content
        cur_article.updatedTime = datetime.now()
        db.session.commit()
        return redirect(url_for('admin.article'))


@admin.route('/article/delete/', methods=['POST', 'GET'])
@system_login
def article_delete():
    cur_article = Article.query.filter_by(id=request.form['id']).first_or_404()
    db.session.delete(cur_article)
    db.session.commit()
    return jsonify(status="success", del_article_id=cur_article.id)


@admin.route('/groups/')
@system_login
def group():
    groups = Group.query.all()
    return render_template('admin/group/index.html',
                           title=gettext('Groups Admin'),
                           groups=groups)


@admin.route('/group/create/', methods=['POST', 'GET'])
@system_login
def group_create():
    if request.method == 'GET':
        return render_template('admin/group/create.html', title=gettext('Create Group'))
    if request.method == 'POST':
        title = request.form['title']
        about = request.form['about']
        new_group = Group(title, about)
        db.session.add(new_group)
        db.session.commit()

        # 保存图片 logo, 注意 upload_img 返回的是元组: (成功或者失败, 相关信息)
        logo = request.files['logo']
        image_path = os.path.join(current_app.config['UPLOAD_FOLDER'], "group_logo", "%d.png" % new_group.id)
        status = upload_img(logo, 200, 200, image_path)
        if status[0]:
            new_group.logo = url_for('static',
                                     filename='upload/group_logo/%d.png' % new_group.id, t=status[1])
            db.session.commit()
            return redirect(url_for('group.group_view', gid=new_group.id))
        else:
            return redirect(url_for('group.group_edit', gid=new_group.id),
                            message=status[1])


@admin.route('/group/<int:gid>/edit/', methods=['POST', 'GET'])
@system_login
def group_edit(gid):
    cur_group = Group.query.filter_by(id=gid).first_or_404()
    if request.method == "GET":
        return render_template('admin/group/edit.html',
                               title=cur_group.title,
                               group=cur_group)
    elif request.method == "POST":
        cur_group.title = request.form['title']
        cur_group.about = request.form['about']
        logo = request.files['logo']
        image_path = os.path.join(current_app.config['UPLOAD_FOLDER'], "group_logo", "%d.png" % cur_group.id)
        status = upload_img(logo, 200, 200, image_path)
        if status[0]:
            cur_group.logo = url_for('static',
                                     filename='upload/group_logo/%d.png' % cur_group.id, t=status[1])
        db.session.commit()
        return redirect(url_for('group.group_view', gid=cur_group.id))


@admin.route('/group/delete/', methods=['POST', 'GET'])
@system_login
def group_delete():
    cur_group = Group.query.filter_by(id=request.form['gid']).first_or_404()
    db.session.delete(cur_group)
    db.session.commit()
    return jsonify(status="success", del_article_id=cur_group.id)


@admin.route('/cases/')
@system_login
def case():
    cases = Case.query.all()
    return render_template('admin/case/index.html',
                           title=gettext('Case Admin'),
                           cases=cases)


@admin.route('/case/create/', methods=['POST', 'GET'])
@system_login
def case_create():
    if request.method == 'GET':
        return render_template('admin/case/create.html', title=gettext('Create Case'))
    if request.method == 'POST':
        if 'op' in request.form and request.form['op'] == 'upload-img':
            path = os.path.join(current_app.config['UPLOAD_FOLDER'], 'case')
            status, uri = receive_img(path, '/static/upload/case', request.files['img'], 0.33, 0.33)
            if status[0]:
                return jsonify(status='success', uri=uri)
            else:
                return jsonify(status="fail")
        else:
            name = request.form['name']
            tags = request.form['tags']
            description = request.form['description']
            new_case = Case(name=name, description=description, tag=tags, icon="/static/images/case/test.png")
            db.session.add(new_case)
            db.session.commit()
            path = os.path.join(current_app.config['CASE_FOLDER'], "%d" % new_case.id)
            os.mkdir(path)
            return redirect(url_for('admin.case'))


@admin.route('/case/<int:case_id>/edit/', methods=['POST', 'GET'])
@system_login
def case_edit(case_id):
    cur_case = Case.query.filter_by(id=case_id).first_or_404()
    if request.method == 'GET':
        if cur_case.tag != '':
            tags = cur_case.tag.split(";")
            return render_template('admin/case/edit_case_info.html',
                                   title=cur_case.name,
                                   case=cur_case,
                                   tags=tags)
        else:
            return render_template('admin/case/edit_case_info.html',
                                   title=cur_case.name,
                                   case=cur_case)
    elif request.method == 'POST':
        if 'op' in request.form and request.form['op'] == 'upload-img':
            path = os.path.join(current_app.config['UPLOAD_FOLDER'], 'case')
            status, uri = receive_img(path, '/static/upload/case', request.files['img'], 1, 1)
            if status[0]:
                return jsonify(status='success', uri=uri)
            else:
                return jsonify(status='fail')
        else:
            cur_case.name = request.form['name']
            cur_case.description = request.form['description']
            cur_case.tag = request.form['tags']
            db.session.commit()
            return jsonify(status="success")


@admin.route('/case/delete/', methods=['POST', 'GET'])
@system_login
def case_delete():
    cur_case = Case.query.filter_by(id=request.form['cid']).first_or_404()
    versions = cur_case.versions
    path = os.path.join(current_app.config['CASE_FOLDER'], '%d' % cur_case.id)
    icon_path = os.path.join(current_app.config['CASE_COVER_FOLDER'], '%d.png' % cur_case.id)
    for v in versions:
        materials = v.materials
        for m in materials:
            v.materials.remove(m)
            db.session.delete(m)
            db.session.commit()
        cur_case.versions.remove(v)
        db.session.delete(v)
        db.session.commit()
    if os.path.exists(icon_path):
        os.remove(icon_path)
    db.session.delete(cur_case)
    db.session.commit()
    # 删除案例目录下所有版本文件, 如果删除失败(文件夹不存在)则继续执行;
    try:
        shutil.rmtree(path)
    except:
        pass
    return jsonify(status='success', del_case_id=cur_case.id)


@admin.route('/case/<int:case_id>/picture/', methods=['GET', 'POST'])
@system_login
def case_icon(case_id):
    if request.method == 'GET':
        cur_case = Case.query.filter_by(id=case_id).first_or_404()
        return render_template('admin/case/edit_case_icon.html', case=cur_case,
                               title=gettext('Case Icon'))
    elif request.method == 'POST':
        # 上传图片和保存图片
        cur_case = Case.query.filter_by(id=case_id).first_or_404()
        icon = request.files['pic']
        if icon.filename == '':
            return jsonify(status='no_file')

        file_type = get_file_type(icon.mimetype)
        if icon and '.' in icon.filename and file_type == 'img':
            icon_name = '%d.png' % cur_case.id
            icon_path = os.path.join(current_app.config['CASE_COVER_FOLDER'], icon_name)
            cur_case.icon = os.path.join('/static/images/case', '%d.png' % cur_case.id)
            db.session.commit()
            status = upload_img(icon, 171, 304, icon_path)
            if status[0]:
                return jsonify(status='success')
            else:
                return jsonify(status='fail')
        else:
            return jsonify(status='file_error')


@admin.route('/case/<int:case_id>/version/', methods=['GET', 'POST'])
@system_login
def case_version(case_id):
    if request.method == 'GET':
        cur_case = Case.query.filter_by(id=case_id).first_or_404()
        all_versions = cur_case.versions
        return render_template('admin/case/edit_case_version.html',
                               title=gettext('Case Version'),
                               versions=all_versions,
                               case=cur_case)
    elif request.method == 'POST':
        # 案例版本的增删查改
        if request.form['op'] == 'create':
            cur_case = Case.query.filter_by(id=case_id).first_or_404()
            all_versions = cur_case.versions
            idx = 0
            for v in all_versions:
                if v.version_id > idx:
                    idx = v.version_id
            cur_version = CaseVersion(case_id=case_id, version_id=idx + 1, name=request.form['name'],
                                      description=request.form['description'])
            cur_version.version_id = idx + 1
            cur_version.dir_path = os.path.join('%d' % case_id, 'version_%d' % cur_version.version_id)
            db.session.add(cur_version)
            cur_case.versions.append(cur_version)
            db.session.commit()
            path = os.path.join(current_app.config['CASE_FOLDER'], cur_version.dir_path)
            os.mkdir(path)
            return jsonify(status='success', id=cur_version.version_id)
        elif request.form['op'] == 'edit':
            cur_case = Case.query.filter_by(id=case_id).first_or_404()
            cur_version = cur_case.versions.filter_by(version_id=request.form['version_id']).first_or_404()
            cur_version.name = request.form['name']
            cur_version.description = request.form['description']
            db.session.commit()
            return jsonify(status='success', id=cur_version.version_id)
        elif request.form['op'] == 'del':
            cur_case = Case.query.filter_by(id=case_id).first_or_404()
            cur_version = cur_case.versions.filter_by(case_id=case_id,
                                                      version_id=request.form['version_id']).first_or_404()
            materials = cur_version.materials
            path = os.path.join(current_app.config['CASE_FOLDER'], cur_version.dir_path)
            for m in materials:
                cur_version.materials.remove(m)
                db.session.delete(m)

            cur_case.versions.remove(cur_version)
            db.session.delete(cur_version)
            db.session.commit()
            # 删除版本目录下所有文件, 如果删除失败(文件夹不存在)则继续执行;
            try:
                shutil.rmtree(path)
            except IOError:
                pass
            return jsonify(status='success', id=cur_version.version_id)
        elif request.form['op'] == 'data':
            cur_version = CaseVersion.query.filter_by(case_id=case_id,
                                                      version_id=request.form['version_id']).first_or_404()
            return jsonify(status='success', name=cur_version.name, description=cur_version.description)


@admin.route('/case/<int:case_id>/version/<int:version_id>/material/', methods=['GET', 'POST'])
@system_login
def case_version_material(case_id, version_id):
    if request.method == 'GET':
        cur_case = Case.query.filter_by(id=case_id).first_or_404()
        cur_version = cur_case.versions.filter_by(version_id=version_id).first_or_404()
        materials = cur_version.materials
        return render_template('admin/case/case_code_materials.html', case=cur_case,
                               version=cur_version,
                               materials=materials,
                               title=gettext('Case Code Material'))
    elif request.method == 'POST':
        # 版本代码文件的删除
        if request.form['op'] == 'del':
            material_ids = request.form.getlist('material_id[]')
            cur_case = Case.query.filter_by(id=case_id).first_or_404()
            cur_version = cur_case.versions.filter_by(version_id=version_id).first_or_404()
            for i in material_ids:
                # 需要在课时对象中删除该资源
                m = cur_version.materials.filter_by(id=i).first_or_404()
                cur_version.materials.remove(m)
                db.session.delete(m)
                db.session.commit()
                try:
                    os.remove(os.path.join(current_app.config['CASE_FOLDER'], cur_version.dir_path, m.name))
                except OSError:
                    pass
            return jsonify(status='success', version_id=version_id)
        elif request.form['op'] == 'upload':
            cur_case = Case.query.filter_by(id=case_id).first_or_404()
            cur_version = cur_case.versions.filter_by(version_id=version_id).first_or_404()
            material = request.files['file']
            material_name = custom_secure_filename(material.filename)
            material_uri = os.path.join('%d' % case_id, 'version_%d' % version_id, '%s' % material_name)
            m = CaseCodeMaterial(name=material_name, uri='', version_id=cur_version.id)
            db.session.add(m)
            cur_version.materials.append(m)
            status = upload_file(material, os.path.join(current_app.config['CASE_FOLDER'], material_uri))
            if status[0]:
                db.session.commit()
                return jsonify(status='success')
            else:
                print status[1]
                cur_version.materials.remove(m)
                db.session.delete(m)
                db.session.commit()
                return jsonify(status='fail')
