#! /usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: xuezaigds@gmail.com
from StringIO import StringIO

from datetime import datetime

from flask import render_template, request, abort, jsonify, send_file
from flask_babel import gettext
from flask_login import current_user, login_required
from sqlalchemy import or_

from eHPC.util.code_process import submit_code
from . import problem
from .. import db
from ..models import Program, Classify, SubmitProblem, Question, UserQuestion, CodeCache


@problem.route('/')
def index():
    return render_template('problem/index.html',
                           title=gettext('Practice Platform'))


@problem.route('/program/')
@login_required
def show_program():
    pro = Program.query.all()
    submission = SubmitProblem.query.filter_by(uid=current_user.id).all()
    cnt = {}
    for i in submission:
        cnt[i.pid] = 0
    for i in submission:
        cnt[i.pid] += 1
    return render_template('problem/show_program.html',
                           title=gettext('Program Practice'),
                           problems=pro,
                           count=cnt)


# 新增一个连接到我的提交界面的路由
@problem.route('/program/submits/<int:pid>/')
@login_required
def show_my_submits(pid):
    my_submits = SubmitProblem.query.filter_by(pid=pid, uid=current_user.id).all()
    pro = Program.query.filter_by(id=pid).first_or_404()
    return render_template('problem/show_my_submits.html',
                           title=gettext('My Submit'),
                           program=pro,
                           submits=my_submits)


# 查看某一次提交的代码
@problem.route('/program/submit/<int:sid>/')
@login_required
def view_code(sid):
    cur_submit = SubmitProblem.query.filter_by(id=sid).first_or_404()
    cur_problem = Program.query.filter_by(id=cur_submit.pid).first_or_404()
    return render_template('problem/view_code.html',
                           title=gettext('Program Practice'),
                           problem=cur_problem,
                           language=cur_submit.language,
                           code=cur_submit.code)


@problem.route('/question/')
def show_question():
    classifies = Classify.query.all()  # 知识点
    rows = []
    for c in classifies:
        rows.append([c.name, c.questions.count(),
                     c.questions.filter(or_(Question.type == 0, Question.type == 1, Question.type == 2)).count(),
                     c.questions.filter(Question.type == 3).count(),
                     c.questions.filter(Question.type == 4).count(),
                     c.questions.filter(Question.type == 5).count(),
                     c.id])

    return render_template('problem/show_question.html',
                           rows=rows)


@problem.route('/program/<int:pid>/', methods=['GET', 'POST'])
@login_required
def program_view(pid):
    if request.method == 'GET':
        cache = CodeCache.query.filter_by(user_id=current_user.id).filter_by(program_id=pid).first()
        pro = Program.query.filter_by(id=pid).first_or_404()
        return render_template('problem/program_detail.html', title=pro.title, problem=pro, cache=cache)
    elif request.method == 'POST':
        if request.form['op'] == 'save':
            program_id = request.form['program_id']
            code = request.form['code']
            cache = CodeCache.query.filter_by(user_id=current_user.id).filter_by(program_id=pid).first()
            if cache:
                cache.code = code
            else:
                cache = CodeCache(current_user.id, program_id, code)
                db.session.add(cache)
            db.session.commit()
            return jsonify(status='success')
        elif request.form['op'] == 'upload':
            return request.files['code'].read()
        elif request.form['op'] == 'download':
            code = StringIO(request.form['code'].encode('utf8'))
            filename = request.form['filename']
            return send_file(code, as_attachment=True, attachment_filename=filename)
        else:
            abort(403)


@problem.route('/question/<question_type>/<int:cid>/')
@login_required
def question_view(cid, question_type):
    classify_name = Classify.query.filter_by(id=cid).first_or_404()

    practices = None
    if question_type == 'choice':
        practices = classify_name.questions.filter(or_(Question.type == 0,
                                                       Question.type == 1, Question.type == 2)).all()
    elif question_type == 'fill':
        practices = classify_name.questions.filter_by(type=3).all()
    elif question_type == 'judge':
        practices = classify_name.questions.filter_by(type=4).all()
    elif question_type == 'essay':
        practices = classify_name.questions.filter_by(type=5).all()
    else:
        abort(404)

    if current_user.is_authenticated:
        user_question = UserQuestion.query.filter_by(user_id=current_user.id, classify_id=cid,
                                                     question_type=question_type).first()
        if user_question:
            user_question.last_time = datetime.now()
            db.session.commit()
        else:
            user_question = UserQuestion(user_id=current_user.id, classify_id=cid,
                                         question_type=question_type, last_time=datetime.now())
            db.session.add(user_question)
            db.session.commit()

    return render_template('problem/practice_detail.html',
                           classify_id=classify_name.id,
                           title=classify_name.name,
                           practices=practices,
                           q_type=question_type)


@problem.route('/<int:pid>/submit/', methods=['POST'])
@login_required
def submit(pid):
    uid = current_user.id
    problem_id = request.form['problem_id']
    source_code = request.form['source_code']
    language = request.form['language']
    submit_problem = SubmitProblem(uid, problem_id, source_code, language)
    db.session.add(submit_problem)
    db.session.commit()

    task_number = request.form['task_number']
    cpu_number_per_task = request.form['cpu_number_per_task']
    node_number = request.form['node_number']

    return submit_code(pid=pid, uid=uid, source_code=source_code,
                       task_number=task_number, cpu_number_per_task=cpu_number_per_task, node_number=node_number, language=language)
