#! /usr/bin/env python
# -*- coding: utf-8 -*-

from flask import render_template, abort, request, redirect, url_for, jsonify, current_app
from . import machine_apply
from datetime import datetime
from ..models import MachineApply, MachineAccount
from flask_babel import gettext
from flask_login import current_user, login_required
from .. import db
import random, string
from io import open


@machine_apply.route('/', methods=['GET', 'POST'])
@login_required
def index():
    if request.method == "GET":
        my_apply = MachineApply.query.filter_by(user_id=current_user.id).first()
        finiehed = 0
        waiting = 0
        unsubmit = 0
        if my_apply:
            if my_apply.submit_status == 0:
                unsubmit += 1
            elif my_apply.submit_status == 1:
                waiting += 1
            elif my_apply.submit_status == 2:
                finiehed += 1
        return render_template('machine_apply/index.html',
                               finished=finiehed,
                               waiting=waiting,
                               unsubmit=unsubmit,
                               title=gettext('Resource Apply'))


@machine_apply.route('/information/')
@login_required
def machine_apply_information():
    return render_template('machine_apply/machine_apply_information.html', title=gettext('Resource Apply Information'))


@machine_apply.route('/machine_applying/')
@login_required
def machine_applying():
    my_apply = MachineApply.query.filter_by(user_id=current_user.id).first()
    if not my_apply:
        # 若此用户还未创建过申请，则显示新建申请界面
        return redirect(url_for('machine_apply.machine_apply_create'))
    else:
        # 若此用户已创建过申请，则直接跳转到编辑申请界面
        return redirect(url_for('machine_apply.machine_apply_edit', apply_id=my_apply.id))


@machine_apply.route('/create/', methods=['GET', 'POST'])
@login_required
def machine_apply_create():
    if request.method == "GET":
        return render_template('machine_apply/create.html', op="create", title=gettext('My Machine Hour Apply'))
    elif request.method == 'POST':
        curr_apply = MachineApply()
        curr_apply.applicant_name = request.form.get('applicant_name')
        curr_apply.applicant_institution = request.form.get('applicant_institution')
        curr_apply.applicant_tel = request.form.get('applicant_tel')
        curr_apply.applicant_email = request.form.get('applicant_email')
        curr_apply.applicant_address = request.form.get('applicant_address')
        curr_apply.manager_name = request.form.get('manager_name')
        curr_apply.manager_institution = request.form.get('manager_institution')
        curr_apply.manager_tel = request.form.get('manager_tel')
        curr_apply.manager_email = request.form.get('manager_email')
        curr_apply.manager_address = request.form.get('manager_address')
        curr_apply.project_name = request.form.get('project_name')
        sc_map = {u"国家超级计算广州中心": 0, u"国家超级计算长沙中心": 1, u"中科院级计算中心": 2, u"国家超级计算上海中心": 3}
        curr_apply.sc_center = sc_map[request.form.get('sc_center')]
        curr_apply.cpu_hour = request.form.get('cpu_hour', 0)  # CPU_hour字段不能置空，若用户未填写则默认为0
        curr_apply.usage = request.form.get('usage')

        curr_apply.user = current_user
        db.session.add(curr_apply)

        if request.form['save-op'] == "submit":
            # 若用户点击“提交”按钮， 提交状态改为1
            curr_apply.submit_status = 1
        else:
            curr_apply.submit_status = 0

        db.session.commit()
        return redirect(url_for('machine_apply.machine_apply_edit', apply_id=curr_apply.id))


@machine_apply.route('/edit/<int:apply_id>/', methods=['GET', 'POST'])
@login_required
def machine_apply_edit(apply_id):
    if request.method == "GET":
        curr_apply = MachineApply.query.filter_by(id=apply_id).first_or_404()
        return render_template('machine_apply/create.html',
                               apply=curr_apply,
                               op="edit",
                               title=gettext('My Machine Hour Apply'),
                               proxy_server=current_app.config['SSH_PROXY_SERVER'])
    elif request.method == 'POST':
        curr_apply = MachineApply.query.filter_by(id=apply_id).first_or_404()
        if request.form.get('save-op') == 'withdraw':
            curr_apply.submit_status = 0
            db.session.commit()
            return render_template('machine_apply/create.html',
                                   apply=curr_apply,
                                   op="edit",
                                   title=gettext('My Machine Hour Apply'))

        curr_apply.applicant_name = request.form.get('applicant_name')
        curr_apply.applicant_institution = request.form.get('applicant_institution')
        curr_apply.applicant_tel = request.form.get('applicant_tel')
        curr_apply.applicant_email = request.form.get('applicant_email')
        curr_apply.applicant_address = request.form.get('applicant_address')
        curr_apply.manager_name = request.form.get('manager_name')
        curr_apply.manager_institution = request.form.get('manager_institution')
        curr_apply.manager_tel = request.form.get('manager_tel')
        curr_apply.manager_email = request.form.get('manager_email')
        curr_apply.manager_address = request.form.get('manager_address')
        curr_apply.project_name = request.form.get('project_name')
        sc_map = {u"国家超级计算广州中心": 0, u"国家超级计算长沙中心": 1, u"中科院级计算中心": 2, u"国家超级计算上海中心": 3}
        curr_apply.sc_center = sc_map[request.form.get('sc_center')]
        curr_apply.cpu_hour = request.form.get('cpu_hour', 0)
        curr_apply.usage = request.form.get('usage')
        curr_apply.submit_status = 1

        if request.form['save-op'] == "submit":
            # 若用户点击“提交”按钮， 提交状态改为1
            curr_apply.submit_status = 1
            curr_apply.applying_time = datetime.now()
            db.session.commit()
            return render_template('machine_apply/create.html',
                                   apply=curr_apply,
                                   op="edit",
                                   title=gettext('My Machine Hour Apply'))
        else:
            # 若用户点击“保存草稿”按钮
            curr_apply.submit_status = 0
            db.session.commit()
            return render_template('machine_apply/create.html',
                                   apply=curr_apply,
                                   op="edit",
                                   save_status="save",
                                   title=gettext('My Machine Hour Apply'))


@machine_apply.route('/ssh/ask-connect/', methods=['POST'])
@login_required
def ask_connect():
    while True:
        token = ''.join(random.sample(string.ascii_letters + string.digits, 32))
        machine_account = MachineAccount.query.filter_by(token=token).first()
        if machine_account is not None:
            continue
        break

    if current_user.machine_account is None:
        return jsonify(status='fail', msg=u'未获得帐号')
    current_user.machine_account.token = token
    db.session.commit()
    return jsonify(status='success', token=token)


@machine_apply.route('/ssh/', methods=['GET', 'POST'])
def get_machine_info():
    op = request.form.get('op', None)
    if op is None:
        return jsonify(status='fail', msg='op is Null')

    if op == 'ssh':
        token = request.form.get('token', None)
        if token is None:
            return jsonify(status='fail', msg='Token lost')

        machine_account = MachineAccount.query.filter_by(token=token).first()
        if machine_account is None:
            return jsonify(status='fail', msg='Invalid token')

        if machine_account.key is not None:
            with open(machine_account.key, 'r') as f:
                private_key = f.read()
            return jsonify(status='success',
                           hostname=machine_account.ip,
                           port=str(machine_account.port),
                           username=machine_account.username,
                           private_key=private_key)
        else:
            return jsonify(status='success',
                           hostname=machine_account.ip,
                           port=str(machine_account.port),
                           username=machine_account.username,
                           password=machine_account.password)


@machine_apply.route('/todo/')
def issue_unsubmit():
    issue_list = MachineApply.query.filter_by(user_id=current_user.id, submit_status=0).all()
    return render_template('machine_apply/issue_list.html',
                           issue_list=issue_list,
                           status='unsubmit',
                           title=gettext('TODO List'))


@machine_apply.route('/waiting/')
def issue_waiting():
    issue_list = MachineApply.query.filter_by(user_id=current_user.id, submit_status=1).all()
    return render_template('machine_apply/issue_list.html',
                           issue_list=issue_list,
                           status='waiting',
                           title=gettext('Waiting List'))


@machine_apply.route('/finished/')
def issue_finished():
    issue_list = MachineApply.query.filter_by(user_id=current_user.id, submit_status=2).all()
    return render_template('machine_apply/issue_list.html',
                           issue_list=issue_list,
                           status='finished',
                           title=gettext('Finished List'))
