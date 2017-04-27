#! /usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: xuezaigds@gmail.com

from threading import Thread
from flask import current_app
from flask import render_template
from flask_mail import Message
from .. import mail


def send_async_email(_app, msg):
    with _app.app_context():
        mail.send(msg)


def send_email(ip, to, subject, template, **kwargs):
    app = current_app._get_current_object()
    app.email_logger.info('remote_ip: %s, to: %s' % (ip, to))
    msg = Message(app.config['MAIL_SUBJECT_PREFIX'] + ' ' + subject,
                  sender=app.config['MAIL_SENDER'], recipients=[to])
    msg.html = render_template(template + '.html', **kwargs)

    # 如果配置文件禁止发送邮件， 这里返回 None
    if current_app.config['MAIL_IS_ON']:
        thr = Thread(target=send_async_email, args=[app, msg])
        thr.start()
        return thr
    else:
        return None
