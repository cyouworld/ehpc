#! /usr/bin/env python
# -*- coding: utf-8 -*-

from flask import render_template, abort, request, redirect, url_for, jsonify
from . import machine_apply
from ..models import MachineApply
from flask_babel import gettext
from flask_login import current_user, login_required
from .. import db


@machine_apply.route('/')
@login_required
def index():
    my_apply = MachineApply.query.filter_by(user_id=current_user.id).first()
    if not my_apply:
        # 若此用户还未创建过申请，则显示新建申请界面
        return render_template('machine_apply/index.html',
                           my_apply=my_apply,
                           title=gettext('Machine Hour Apply'))
    else:
        # 若此用户已创建过申请，则直接跳转到编辑申请界面
        return redirect(url_for('machine_apply.machine_apply_edit', apply_id=my_apply.id))


@machine_apply.route('/create', methods=['GET', 'POST'])
@login_required
def machine_apply_create():
    if request.method == "GET":
        return render_template('machine_apply/create.html', op="create", title=gettext('Machine Hour Apply Create'))
    elif request.method == 'POST':
        curr_apply = MachineApply(project_user_institution=request.form['project-user-institution'],
                                  project_user_tel=request.form['project-user-tel'],
                                  project_user_address=request.form['project-user-address'],
                                  project_applicant_institution=request.form['project-applicant-institution'],
                                  project_applicant_tel=request.form['project-applicant-tel'],
                                  project_applicant_address=request.form['project-applicant-address'],
                                  project_name=request.form['project-name'],
                                  sc_center=request.form['sc-center'],
                                  CPU_hour=request.form['cpu-hour'],
                                  user_id=current_user.id)
        db.session.add(curr_apply)
        db.session.commit()
        if request.form['save-op'] == "submit":
            # 若用户点击“提交”按钮， 提交状态改为1，To Do
            print "submit"
        else:
            # 若用户点击“保存草稿”按钮， To Do
            print "save-as-draft"
        return redirect(url_for('machine_apply.machine_apply_edit', apply_id=curr_apply.id))


@machine_apply.route('/edit/<int:apply_id>', methods=['GET', 'POST'])
@login_required
def machine_apply_edit(apply_id):
    if request.method == "GET":
        curr_apply = MachineApply.query.filter_by(id=apply_id).first_or_404()
        return render_template('machine_apply/create.html',
                               apply=curr_apply,
                               op="edit",
                               title=gettext('Machine Hour Apply Edit'))
    elif request.method == 'POST':
        curr_apply = MachineApply.query.filter_by(id=apply_id).first_or_404()
        if request.form['save-op'] == "submit":
            # 若用户点击“提交”按钮， 提交状态改为1，To Do
            print "submit"
            return render_template('machine_apply/create.html',
                                   apply=curr_apply,
                                   op="edit",
                                   title=gettext('Machine Hour Apply Edit'))
        else:
            # 若用户点击“保存草稿”按钮， To Do
            print "save-as-draft"
            return render_template('machine_apply/create.html',
                                   apply=curr_apply,
                                   op="edit",
                                   save_status="save",
                                   title=gettext('Machine Hour Apply Edit'))
