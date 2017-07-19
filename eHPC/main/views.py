#! /usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: xuezaigds@gmail.com

from flask import render_template
from . import main
from ..models import Course, Group, Article, Post, SubmitProgram, Program, Progress
from flask_babel import gettext
from flask_wtf.csrf import CSRFError
from flask_login import current_user


@main.route('/')
def index():
    courses = Course.query.order_by(Course.nature_order.asc()).limit(6).all()
    groups = Group.query.order_by(Group.memberNum.desc()).limit(6).all()
    articles = Article.query.order_by(Article.updatedTime.desc()).limit(5).all()
    if current_user.is_authenticated:
        user_posts = current_user.posts.order_by(Post.createdTime.desc()).limit(8).all()
        user_topics = []
        for p in user_posts:
            user_topics.append(p.topic)
        user_courses = current_user.courses.limit(8).all()

        # 获取当前登录用户最近提交过的编程题目(最近5个)
        user_submits = SubmitProgram.query.order_by(
            SubmitProgram.submit_time.desc()).filter_by(uid=current_user.id).all()
        user_program = []
        aux = set()
        for s in user_submits:
            if s.pid not in aux:
                aux.add(s.pid)
                sub_problem = Program.query.filter_by(id=s.pid).first()
                user_program.append(sub_problem)
        user_program = user_program[:5]

        # 获取当前登录用户最近正在进行, 仍然没有完成的实验任务(最近5个)
        all_challenges = Progress.query.order_by(Progress.update_time.desc()).filter_by(user_id=current_user.id).all()
        user_challenges = []
        count = 0
        for ac in all_challenges:
            if count > 5:
                break
            challenges_count = ac.knowledge.challenges.count()
            if ac.cur_progress < challenges_count:
                user_challenges.append(ac)
                count += 1

        if user_courses or user_topics or user_program or user_challenges:
            return render_template('main/personal_index.html',
                                   title=gettext('Education Practice Platform'),
                                   user_courses=user_courses,
                                   user_topics=user_topics,
                                   user_program=user_program,
                                   user_challenges=user_challenges)
        else:
            return render_template('main/index.html',
                                   title=gettext('Education Practice Platform'),
                                   courses=courses,
                                   groups=groups,
                                   articles=articles)
    else:
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
