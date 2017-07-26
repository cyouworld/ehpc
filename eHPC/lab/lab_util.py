#! /usr/bin/env python
# -*- coding: utf-8 -*-

from datetime import datetime
from flask_login import current_user, current_app
from flask import jsonify

from .. import db
from ..models import Progress, VNCProgress, Statistic, VNCTask
import json


def get_progress_class(kid):
    """ 如果用户进度表中没有进度记录， 则添加一条，初始化学习记录为 0
    """
    pro = Progress.query.filter_by(user_id=current_user.id).filter_by(knowledge_id=kid).first()
    if pro is None:
        pro = Progress(user_id=current_user.id, knowledge_id=kid, update_time=datetime.now())
        db.session.add(pro)
        db.session.commit()
    return pro


def get_cur_progress(kid):
    """ 返回当前登录用户在 knowledge(kid) 上学习过的最后一个知识点序号

    如果用户刚开始学习，则返回 0
    """
    pro = get_progress_class(kid)
    pro.update_time = datetime.now()
    db.session.commit()
    return pro.cur_progress


def increase_progress(kid, k_num, challenges_count):
    """ 为当前登录用户在 knowledge(kid) 上学习的知识号加1

    :param kid: knowledge 的标识符
    :param k_num: 当前学习的 challenge 序号， 为 unicode 类型。
    :param challenges_count: 当前 knowledge 所有的 challenge 数目
    """
    pro = get_progress_class(kid)
    if int(k_num) == (pro.cur_progress + 1) <= challenges_count:
        pro.cur_progress += 1
        db.session.commit()


def get_vnc_progress_class(kid):
    pro = VNCProgress.query.filter_by(user_id=current_user.id).filter_by(vnc_knowledge_id=kid).first()
    if pro is None:
        pro = VNCProgress(user_id=current_user.id, vnc_knowledge_id=kid, update_time=datetime.now())
        db.session.add(pro)
        db.session.commit()
    return pro


def get_cur_vnc_progress(kid):
    pro = get_vnc_progress_class(kid)
    pro.update_time = datetime.now()
    db.session.commit()
    return pro.have_done


def increase_vnc_progress(kid, vnc_task_num, tasks_count):
    pro = get_vnc_progress_class(kid)
    if int(vnc_task_num) == (pro.have_done + 1) <= tasks_count:
        pro.have_done += 1
        db.session.commit()
