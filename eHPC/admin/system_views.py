#! /usr/bin/env python
# -*- coding: utf-8 -*-
from flask import render_template, request, redirect, url_for, abort, jsonify, current_app
from datetime import datetime
from ..user.authorize import system_login
from . import admin
from ..models import User, Classify, Article, Group
from .. import db
from flask_babel import gettext
import os
from ..util.upload_file import upload_img


@admin.route('/')
@system_login
def index():
    return render_template('admin/system.html',
                           title=gettext("System Admin"))


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
            return redirect(url_for('group.group_edit', gid=new_group),
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
