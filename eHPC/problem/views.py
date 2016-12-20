#! /usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: xuezaigds@gmail.com
from flask import render_template, jsonify, request, abort
from flask_login import current_user, login_required
from . import problem
from ..models import Program, Classify, SubmitProblem, Question
from flask_babel import gettext
from ..problem.code_process import ehpc_client
from .. import db
from sqlalchemy import or_


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
        rows.append([c.name, c.questions.count(), c.id])

    return render_template('problem/show_question.html',
                           title=gettext('Choice Practice'),
                           rows=rows)


@problem.route('/program/<int:pid>/')
@login_required
def program_view(pid):
    pro = Program.query.filter_by(id=pid).first_or_404()
    return render_template('problem/program_detail.html',
                           title=pro.title,
                           problem=pro)


@problem.route('/question/<question_type>/<int:cid>/')
@login_required
def question_view(cid, question_type):
    classify_name = Classify.query.filter_by(id=cid).first_or_404()

    practices = None;
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
    uid = current_user.id
    problem_id = request.form['problem_id']
    source_code = request.form['source_code']
    language = request.form['language']
    submit_problem = SubmitProblem(uid, problem_id, source_code, language)
    db.session.add(submit_problem)
    db.session.commit()

    path = "/HOME/sysu_dwu_1/coreos"
    input_filename = "%s_%s.c" % (str(pid), str(uid))
    output_filename = "%s_%s.o" % (str(pid), str(uid))

    # with open(input_filename, 'w') as src_file:
    # src_file.write(source_code)

    client = ehpc_client()

    is_success = client.login()
    if not is_success:
        print "login fail."

    is_success = client.upload(path, input_filename, source_code)
    if not is_success:
        print "upload fail."

    compile_command = "bash -c 'cd %s;g++ -o %s %s'" % (path, output_filename, input_filename)
    run_command = "bash -c 'cd %s;./%s'" % (path, output_filename)

    compile_output = client.run_command(compile_command)
    compile_out = compile_output or "Compile success."
    if compile_output is None:
        compile_out = "Request fail."

    run_output = client.run_command(run_command)
    run_out = run_output or "No output."
    if run_output is None:
        run_out = "Request fail."

    '''
    # TODO here.  Get the result.
    is_compile_success = [False]
    compile_out = c_compile(source_code, pid, current_user.id, is_compile_success)
    run_out = "编译失败!\n程序无法运行..."
    if is_compile_success[0]:
        run_out = c_run(pid, current_user.id) or "程序无输出结果"
    '''
    result = dict()
    result['status'] = 'success'
    result['problem_id'] = pid
    result['compile_out'] = str(compile_out)
    result['run_out'] = str(run_out)
    return jsonify(**result)
