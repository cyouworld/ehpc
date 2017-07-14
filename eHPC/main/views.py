#! /usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: xuezaigds@gmail.com

from flask import render_template
from . import main
from ..models import Course, Group, Article, Statistic
from flask_babel import gettext
from flask_wtf.csrf import CSRFError
from flask_login import current_user


@main.route('/')
def index():
    courses = Course.query.order_by(Course.nature_order.asc()).limit(6).all()
    groups = Group.query.order_by(Group.memberNum.desc()).limit(6).all()
    articles = Article.query.order_by(Article.updatedTime.desc()).limit(5).all()
    if current_user.is_authenticated:
        return render_template('main/personal_index.html',
                               title=gettext('Education Practice Platform'),
                               statistics=current_user.statistics)
    return render_template('main/index.html',
                           title=gettext('Education Practice Platform'),
                           courses=courses,
                           groups=groups,
                           articles=articles)


@main.app_errorhandler(404)
def page_404(err):
    return render_template('404.html', title='404'), 404


@main.app_errorhandler(403)
def page_403(err):
    return render_template('403.html', title='403'), 403


@main.app_errorhandler(500)
def page_500(err):
    return render_template('500.html', title='500'), 500


@main.app_errorhandler(CSRFError)
def handle_csrf_error(err):
    return render_template('403.html', title='403'), 403
