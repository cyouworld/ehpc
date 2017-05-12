#! /usr/bin/env python
# -*- coding: utf-8 -*-

from flask import render_template, abort, request, redirect, url_for
from . import machine_apply
from ..models import MachineApply
from flask_babel import gettext
from flask_login import current_user, login_required
from .. import db


@machine_apply.route('/')
@login_required
def index():
    my_applies = MachineApply.query.filter_by(user_id=current_user.id).order_by(MachineApply.applying_time.asc())
    return render_template('machine_apply/index.html',
                           all_applies=my_applies,
                           title=gettext('Machine Hour Apply'))


@machine_apply.route('/create', methods=['GET', 'POST'])
@login_required
def machine_apply_create():
    if request.method == "GET":
        return render_template('machine_apply/create.html', op="create", title=gettext('Machine Hour Apply Create'))
    elif request.method == 'POST':
        #To DO
        return redirect(url_for('machine_apply.index'))


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
        #To DO
        return redirect(url_for('machine_apply.index'))
