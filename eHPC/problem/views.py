#! /usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: xuezaigds@gmail.com
from StringIO import StringIO

from datetime import datetime, time

from flask import render_template, request, abort, jsonify, send_file
from flask_babel import gettext
from flask_login import current_user, login_required
from sqlalchemy import or_

from config import TH2_MY_PATH, TH2_MAX_NODE_NUMBER
from eHPC.util.new_api import submit_code_new, run_evaluate_program
from . import problem
from .. import db
from ..models import Program, Classify, SubmitProgram, Question, CodeCache, Statistic
import json


@problem.route('/')
def index():
    return render_template('problem/index.html',
                           title=gettext('Practice Platform'))


@problem.route('/program/')
@login_required
def show_program():
    pro = Program.query.all()
    submission = SubmitProgram.query.filter_by(uid=current_user.id).all()
    cnt = {}
    for i in submission:
        cnt[i.pid] = 0
    for i in submission:
        cnt[i.pid] += 1
    return render_template('problem/show_program.html',
                           title=gettext('Program Practice'),
                           programs=pro,
                           count=cnt)


# 新增一个连接到我的提交界面的路由
@problem.route('/program/submits/<int:pid>/')
@login_required
def show_my_submits(pid):
    my_submits = SubmitProgram.query.filter_by(pid=pid, uid=current_user.id).order_by(SubmitProgram.submit_time.desc())
    pro = Program.query.filter_by(id=pid).first_or_404()
    return render_template('problem/show_my_submits.html',
                           title=gettext('My Submit'),
                           program=pro,
                           submits=my_submits)


# 查看某一次提交的代码
@problem.route('/program/submit/<int:sid>/')
@login_required
def view_code(sid):
    cur_submit = SubmitProgram.query.filter_by(id=sid).first_or_404()
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
                           rows=rows, title=u'知识点选择列表')


@problem.route('/program/<int:pid>/', methods=['GET', 'POST'])
@login_required
def program_view(pid):
    if request.method == 'GET':
        cache = CodeCache.query.filter_by(user_id=current_user.id).filter_by(program_id=pid).first()
        pro = Program.query.filter_by(id=pid).first_or_404()
        return render_template('problem/program_detail.html', title=pro.title, program=pro, cache=cache)
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
    return render_template('problem/practice_detail.html',
                           classify_id=classify_name.id,
                           title=classify_name.name,
                           practices=practices,
                           q_type=question_type)


@problem.route('/<int:pid>/submit/', methods=['POST'])
@login_required
def submit(pid):
    cpu_number = request.form['cpu_number']
    node_number = int(cpu_number) / 24 + 1

    if node_number < 2:

        uid = current_user.id
        program_id = request.form['program_id']
        source_code = request.form['source_code']
        language = request.form['language']
        submit_program = SubmitProgram(uid, program_id, source_code, language)
        db.session.add(submit_program)
        db.session.commit()
        if language == "openmp":
            cpu_number_per_task = cpu_number
            task_number = 1
        elif language == "mpi":
            task_number = cpu_number
            cpu_number_per_task = 1

        return submit_code_new(pid=pid, uid=uid, source_code=source_code, task_number=task_number, cpu_number_per_task=cpu_number_per_task, language=language)
    else:
        op = request.form['job_op']
        jobid = request.form['job_id']

        uid = current_user.id
        source_code = ''
        language = ''
        task_number = 0
        cpu_number_per_task = 0

        if op == '1':
            uid = current_user.id
            problem_id = request.form['problem_id']
            source_code = request.form['source_code']
            language = request.form['language']
            submit_program = SubmitProgram(uid, problem_id, source_code, language)
            db.session.add(submit_program)
            db.session.commit()

            if language == "openmp":
                cpu_number_per_task = cpu_number
                task_number = 1
            elif language == "mpi":
                task_number = cpu_number
                cpu_number_per_task = 1

        return submit_code(pid=pid, uid=uid, source_code=source_code, task_number=task_number, cpu_number_per_task=cpu_number_per_task,
                       node_number=node_number, language=language, op=op, jobid=jobid)


@problem.route('/<int:pid>/evaluate/', methods=['POST'])
@login_required
def evaluate(pid):
    uid = current_user.id
    cpu_num = request.form['cpu_number']
    source_code = request.form['source_code']
    if request.form['step_num']:
        step_num = int(request.form['step_num'])
    else:
        step_num = 1

    result = dict()
    result['status'] = 'error'
    result['run_out'] = '{' + run_evaluate_program(str(pid), str(uid), source_code, cpu_num, step_num) + "}"
    result['status'] = 'success'
    result['cpu_num'] = cpu_num
    result['step_num'] = step_num
    print result
    return jsonify(**result)
