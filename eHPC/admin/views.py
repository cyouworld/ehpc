#! /usr/bin/env python
# -*- coding: utf-8 -*-
from datetime import datetime

from flask import render_template, request, redirect, url_for, session
from flask_babel import gettext
from flask_login import login_user, logout_user, current_user

from eHPC.util.captcha import verify_captcha
from . import admin
from .. import db
from ..models import User, Article, Group, Case, Classify, Course, DockerHolder, Knowledge, VNCKnowledge
from ..user.authorize import admin_login, system_login, teacher_login
import threading
from utils import save_address


@admin.route('/auth/', methods=["GET", "POST"])
def auth():
    if request.method == "GET":
        return render_template('admin/auth.html', title=gettext("Admin Auth"))

    elif request.method == "POST":
        _form = request.form
        resp = _form.get('luotest_response')
        if not verify_captcha(resp):
            message = u'人机识别验证失败'
            return render_template('admin/auth.html', title=gettext("Admin Auth"), message=message)

        u = User.query.filter_by(email=_form['email']).first()
        if u and u.verify_password(_form['password']) and u.permissions == 0:
            login_user(u)
            u.last_login = datetime.now()
            db.session.commit()

            if request.headers.getlist("X-Forwarded-For"):
                ip = request.headers.getlist("X-Forwarded-For")[0]
            else:
                ip = request.remote_addr

            save_address(ip)

            return redirect(request.args.get('next') or url_for('admin.system'))
        else:
            message = gettext('Invalid username or password.')
            return render_template('admin/auth.html', title=gettext('Admin Auth'),
                                   form=_form,
                                   message=message)


@admin.route('/logout/')
@admin_login
def logout():
    logout_user()
    return redirect(request.args.get('next') or request.referrer or url_for('admin.auth'))


@admin.route('/teacher/')
@teacher_login
def teacher():
    # if 'admin_course_tag' in session:  # 展开session中记录的课程子菜单
    #     return render_template("admin/teacher.html", title=gettext("Teacher Setting"),
    #                            classify=current_user.teacher_classify,
    #                            tag1=session['admin_course_tag'])
    if session.get('admin_url') is not None:
        url = session.get('admin_url')
        if url.find('tag') != -1:
            url = '/admin%s' % session.get('admin_url').split('admin')[1]
        return redirect(url)

    return render_template("admin/teacher.html", title=gettext("Teacher Setting"),
                           classify=current_user.teacher_classify)


@admin.route('/system/')
@system_login
def system():
    user_cnt = User.query.count()
    article_cnt = Article.query.count()
    group_cnt = Group.query.count()
    case_cnt = Case.query.count()
    lab_cnt = Knowledge.query.count() + VNCKnowledge.query.count()
    return render_template("admin/system.html",
                           user_cnt=user_cnt,
                           article_cnt=article_cnt,
                           group_cnt=group_cnt,
                           case_cnt=case_cnt,
                           course_cnt=Course.query.count(),
                           docker_holder_cnt=DockerHolder.query.count(),
                           lab_cnt=lab_cnt,
                           title=gettext("System Setting"))
