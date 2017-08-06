#! /usr/bin/env python
# -*- coding: utf-8 -*-

from ..models import Notification, User, NotificationReceiver
from .. import db
from datetime import datetime
from flask_login import current_user


def send_message(event_name, event_content, sender, receivers):
    """
    向receivers发送站内通知
    :param event_name: 事件名称
    :param event_content: 事件内容 str
    :param sender: 发送者 User
    :param receivers: 接收者 list
    :return: True or False
    """
    if not isinstance(event_content, str):
        print('event_content is not str type')
        return False
    if not isinstance(sender, User):
        print('sender is not User type')
        return False
    if not isinstance(receivers, list):
        print('receivers is not list type')
        return False

    notification = Notification(event_name, event_content)
    notification.sender = sender
    db.session.add(notification)

    for r in receivers:
        note_info = NotificationReceiver()
        note_info.notification = notification
        note_info.receiver = r
        db.session.add(note_info)

    db.session.commit()
    return True


def read_message(note_info_id):
    note_info = current_user.note_info.filter_by(id=note_info_id).first()
    if note_info is None:
        return False, None

    note_info.is_read = True
    note_info.read_time = datetime.now()
    db.session.commit()
    return True, note_info
