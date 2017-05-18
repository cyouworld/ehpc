#! /usr/bin/env python
# -*- coding: utf-8 -*-
from flask import render_template, request, redirect, url_for, abort, jsonify
from flask_login import login_user, current_user, login_required, logout_user
from datetime import datetime
from ..user.authorize import admin_login, system_login, teacher_login
from ..util.user_manage import is_admin_user, is_teacher_user
from . import admin
from ..models import User, Article, Group, Case, CaseVersion, CaseCodeMaterial, Classify
from .. import db
from flask_babel import gettext


@admin.route('/auth/', methods=["GET", "POST"])
def auth():
    if request.method == "GET":
        return render_template('admin/auth.html', title=gettext("Admin Auth"))

    elif request.method == "POST":
        _form = request.form
        u = User.query.filter_by(email=_form['email']).first()
        if u and u.verify_password(_form['password']) and u.permissions == 0:
            login_user(u)
            u.last_login = datetime.now()
            db.session.commit()
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
    return render_template("admin/teacher.html", title=gettext("Teacher Setting"), classify=Classify.query.all())


@admin.route('/system/')
@system_login
def system():
    user_cnt = User.query.count()
    article_cnt = Article.query.count()
    group_cnt = Group.query.count()
    case_cnt=Case.query.count()
    return render_template("admin/system.html",
                           user_cnt=user_cnt,
                           article_cnt=article_cnt,
                           group_cnt=group_cnt,
                           case_cnt=case_cnt,
                           title=gettext("System Setting"))

