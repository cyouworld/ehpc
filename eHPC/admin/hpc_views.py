#! /usr/bin/env python
# -*- coding: utf-8 -*-
import os

import pdfkit
from flask import render_template, request, redirect, url_for, jsonify, current_app, send_file

from . import admin
from .. import db
from ..models import MachineApply, MachineAccount
from ..user.authorize import hpc_login
from ..util.email import send_email_with_attach


@admin.route('/hpc/')
@hpc_login
def machine_apply_index():
    return redirect(url_for('admin.machine_apply_gz'))


@admin.route('/hpc/guangzhou/')
@hpc_login
def machine_apply_gz():
    applies = MachineApply.query.filter_by(sc_center=0).all()
    return render_template('admin/hpc/index.html',
                           applies=applies,
                           sc_center=0,
                           title=u'机时申请')


@admin.route('/hpc/changsha/')
@hpc_login
def machine_apply_cs():
    applies = MachineApply.query.filter_by(sc_center=1).all()
    return render_template('admin/hpc/index.html',
                           applies=applies,
                           sc_center=1,
                           title=u'机时申请')


@admin.route('/hpc/zhongkeyuan/')
@hpc_login
def machine_apply_zky():
    applies = MachineApply.query.filter_by(sc_center=2).all()
    return render_template('admin/hpc/index.html',
                           applies=applies,
                           sc_center=2,
                           title=u'机时申请')


@admin.route('/hpc/shanghai/')
@hpc_login
def machine_apply_sh():
    applies = MachineApply.query.filter_by(sc_center=3).all()
    return render_template('admin/hpc/index.html',
                           applies=applies,
                           sc_center=3,
                           title=u'机时申请')


@admin.route('/hpc/<int:apply_id>/', methods=['GET', 'POST'])
@hpc_login
def machine_apply(apply_id):
    if request.method == 'GET':
        curr_apply = MachineApply.query.filter_by(id=apply_id).first_or_404()
        return render_template('admin/hpc/detail.html', apply=curr_apply, title=u'机时申请')
    elif request.method == 'POST':
        curr_apply = MachineApply.query.filter_by(id=apply_id).first_or_404()
        op = request.form.get('op')
        if op == 'approve':
            return jsonify(status='success', url=url_for('admin.machine_apply_password', apply_id=apply_id))
        elif op == 'disapprove':
            curr_apply.submit_status = 3
            db.session.commit()
            return jsonify(status='success', url=url_for('admin.machine_apply', apply_id=apply_id))
        elif op == 'export':
            return jsonify(status='success', url=url_for('admin.machine_download', apply_id=apply_id))
        elif op == 'edit':
            return jsonify(status='success', url=url_for('admin.machine_apply_edit', apply_id=apply_id))
        elif op == 'key':
            return jsonify(status='success', url=url_for('admin.machine_apply_password', apply_id=apply_id))


@admin.route('/hpc/<int:apply_id>/download/', methods=['GET', 'POST'])
@hpc_login
def machine_download(apply_id):
    curr_apply = MachineApply.query.filter_by(id=apply_id).first_or_404()
    opt = {
        'page-height': '210mm',
        'page-width': '298mm',
        'margin-top': '0.75in',
        'margin-right': '0.75in',
        'margin-bottom': '0.75in',
        'margin-left': '0.75in',
        'encoding': 'UTF-8'
    }
    path = os.path.join(current_app.config['DOWNLOAD_FOLDER'], 'apply%d.pdf' % apply_id)
    pdfkit.from_string(render_template('admin/hpc/apply_pdf.html', apply=curr_apply, title=u'机时申请'), path, options=opt)
    return send_file(path, as_attachment=True, attachment_filename='apply%d.pdf' % apply_id)


@admin.route('/hpc/<int:apply_id>/password/', methods=['GET', 'POST'])
@hpc_login
def machine_apply_password(apply_id):
    if request.method == 'GET':
        curr_apply = MachineApply.query.filter_by(id=apply_id).first_or_404()
        curr_account = None if not curr_apply.account else curr_apply.account
        return render_template('admin/hpc/password.html', apply=curr_apply, title=u'机时申请', account=curr_account)
    elif request.method == 'POST':
        curr_apply = MachineApply.query.filter_by(id=apply_id).first_or_404()
        curr_user = curr_apply.user
        account = curr_apply.account

        # 判断是否机器重复
        username = request.form.get('username')
        aux = MachineAccount.query.filter_by(sc_center=curr_apply.sc_center).filter_by(username=username).first()
        if aux and (account is None or account and aux.id != account.id):
            return render_template('admin/hpc/password.html', apply=curr_apply, title=u'机时申请', info=u'用户已存在')

        # 创建账户
        if account is None:
            account = MachineAccount()
            account.user = curr_user
            account.apply = curr_apply
            db.session.add(account)
            db.session.commit()

        id_rsa = request.files.get('key')
        key_path = os.path.join(current_app.config['KEY_FOLDER'], 'id_ras_%d' % account.id)
        id_rsa.save(key_path)
        account.key = key_path

        account.ip = request.form.get('ip')
        account.port = request.form.get('port')
        account.username = request.form.get('username')
        account.password = request.form.get('password')
        account.sc_center = curr_apply.sc_center
        db.session.commit()

        curr_user.machine_accounts.append(account)
        db.session.commit()

        if request.headers.getlist("X-Forwarded-For"):
            ip = request.headers.getlist("X-Forwarded-For")[0]
        else:
            ip = request.remote_addr

        send_email_with_attach(ip, curr_apply.user.email, u'秘钥信息',
                               'admin/hpc/apply_email', 'id_rsa', account.key,
                               user=account.user, account=account)

        curr_apply.submit_status = 2
        db.session.commit()

        return redirect(url_for('admin.machine_apply_index'))


@admin.route('/hpc/<int:apply_id>/edit/', methods=['GET', 'POST'])
@hpc_login
def machine_apply_edit(apply_id):
    if request.method == 'GET':
        curr_apply = MachineApply.query.filter_by(id=apply_id).first_or_404()
        return render_template('admin/hpc/edit.html', apply=curr_apply, title=u'编辑机时申请')
    elif request.method == 'POST':
        curr_apply = MachineApply.query.filter_by(id=apply_id).first_or_404()
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
        db.session.commit()
        return redirect(url_for('admin.machine_apply', apply_id=apply_id))
