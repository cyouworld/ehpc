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
from ..models import User
from ..util.email import send_email
from .. import db
from ..util.file_manage import get_file_type
from ..user.authorize import system_login

alphanumeric = re.compile(r'^[0-9a-zA-Z\_]*$')
email_address = re.compile(r'[a-zA-z0-9]+\@[a-zA-Z0-9]+\.+[a-zA-Z]')


@user.route('/signin/', methods=['GET', 'POST'])
def signin():
    if request.method == 'GET':
        if current_user.is_authenticated:
            return redirect(request.args.get('next') or url_for("main.index"))
        return render_template('user/signin.html',
                               title=gettext('User Sign In'),
                               form=None)
    elif request.method == 'POST':
        session.permanent = True
        current_app.permanent_session_lifetime = timedelta(days=1)
        next_url = request.args.get('next')
        if next_url:
            next_url = None if request.args.get('next')[:6] == '/user/' else request.args.get('next')
        _form = request.form
        resp = _form.get('luotest_response')
        if not verify_captcha(resp):
            message = u'人机识别验证失败'
            return render_template('user/signin.html', title=gettext('User Sign In'),
                                   form=_form, message=message)

        u = User.query.filter_by(email=_form['email']).first()
        if u and u.verify_password(_form['password']):
            login_user(u)
            u.last_login = datetime.now()
            db.session.commit()
            return redirect(next_url or url_for('main.index'))
        else:
            message = gettext('Invalid username or password.')
            return render_template('user/signin.html', title=gettext('User Sign In'),
                                   form=_form, message=message)


@user.route('/signout/')
@login_required
def signout():
    logout_user()
    return redirect(request.args.get('next') or request.referrer or url_for('main.index'))


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
                                   form=_form, message_captcha=message_captcha)

        username = _form['username']
        email = _form['email']
        password = _form['password']
        password2 = _form['password2']

        name = _form.get('name')
        gender = _form.get('gender', 1)
        phone = _form.get('phone')
        university = _form.get('university')
        student_id = _form.get('student_id', 0)

        message_e, message_u, message_p = "", "", ""
        # Check username is valid or not.
        if User.query.filter_by(username=username).first():
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
            reg_user.username = username
            reg_user.email = email
            reg_user.password = password
            reg_user.name = name
            reg_user.gender = gender
            reg_user.phone = phone
            reg_user.university = university
            reg_user.student_id = student_id
            reg_user.avatar_url = 'none.jpg'

            db.session.add(reg_user)
            db.session.commit()
            login_user(reg_user)

            if _form.get('type') == '1':
                if request.headers.getlist("X-Forwarded-For"):
                    ip = request.headers.getlist("X-Forwarded-For")[0]
                else:
                    ip = request.remote_addr

                send_email(ip, current_app.config['MAIL_USERNAME'], u'教师用户注册提醒', 'user/reg_teacher_email', user=reg_user)

            # TODO, Confirm the email.
            return redirect(request.args.get('next') or url_for('main.index'))


@system_login
@user.route('/register/teacher/<int:user_id>/', methods=['GET', 'POST'])
def reg_teacher(user_id):
    if request.method == 'GET':
        u = User.query.filter_by(id=user_id).first_or_404()
        return render_template('user/reg_teacher.html', user=u)
    elif request.method == 'POST':
        if request.form.get('op') == 'approve':
            u = User.query.filter_by(id=user_id).first_or_404()
            u.permissions = 2
            db.session.commit()
        return redirect(url_for('admin.user'))


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


@user.route('/<int:uid>/')
def info(uid):
    u = User.query.filter_by(id=uid, deleted=False).first_or_404()

    per_page = current_app.config['PER_PAGE']
    page = int(request.args.get('page', 1))
    offset = (page - 1) * per_page
    topics_all = list(filter(lambda t: not t.deleted, u.extract_topics()))
    topics_all.sort(key=lambda t: (t.reply_count, t.click), reverse=True)
    topics = topics_all[offset:offset + per_page]
    pagination = Pagination(page=page, total=len(topics_all),
                            per_page=per_page,
                            record_name='topics',
                            CSS_FRAMEWORK='bootstrap',
                            bs_version=3)
    return render_template('user/info.html',
                           topics=topics,
                           title=u.username + gettext("'s Topics"),
                           post_list_title=u.username + gettext("'s Topics"),
                           pagination=pagination,
                           user=u)


@user.route('/setting/')
@login_required
def setting():
    if request.method == 'GET':
        return render_template('user/setting.html',
                               title=gettext("Setting"),
                               form=None)


@user.route('/setting/info', methods=['GET', 'POST'])
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
