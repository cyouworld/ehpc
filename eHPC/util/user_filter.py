#! /usr/bin/env python
# -*- coding: utf-8 -*-
from . import filter_blueprint
from flask_babel import gettext
import time
import hashlib


@filter_blueprint.app_template_filter('is_admin_user')
def is_admin_user(u):
    if u.is_authenticated and (u.permissions == 0 or u.permissions == 2):
        return True
    return False


@filter_blueprint.app_template_filter('is_student_user')
def is_student_user(u):
    if u.is_authenticated and u.permissions == 1:
        return True
    return False


@filter_blueprint.app_template_filter('is_teacher_user')
def is_teacher_user(u):
    if u.is_authenticated and u.permissions == 2:
        return True
    return False


@filter_blueprint.app_template_filter('is_system_user')
def is_system_user(u):
    if u.is_authenticated and u.permissions == 0:
        return True
    return False


@filter_blueprint.app_template_filter('show_role')
def show_role(u):
    if u.permissions == 2:
        return u'教师'
    elif u.permissions == 1 and u.student_type == 0:
        return u'本科生'
    elif u.permissions == 1 and u.student_type == 1:
        return u'研究生'
    elif u.permissions == 0:
        return u'系统管理员'
    elif u.permissions == 3:
        return u'机时管理员'
    else:
        return u'未知'


@filter_blueprint.app_template_filter('get_contest_url')
def get_contest_url(u):
    timestamp = int(time.time())
    base_url = 'http://114.67.37.238:8007/JYPT/module/index/index.html'
    args = 'userName=%s&level=1&timestamp=%s' % (u.username, timestamp)
    hash_value = hashlib.sha256(args).hexdigest()
    args += '&hash=%s' % hash_value
    url = base_url + '?' + args
    return url
