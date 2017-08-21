#! /usr/bin/env python
# -*- coding: utf-8 -*-
from flask import render_template, jsonify, request, abort, url_for, redirect, make_response
from flask_login import current_user, login_required, current_app
from ..models import User, Course, QRcode
from .. import db
from . import wechat
from ..user.authorize import teacher_login
from wechat_tools import Wechat
import qrcode, os
from datetime import datetime, timedelta


@wechat.route('/', methods=['GET', 'POST'])
def process():
    """处理微信方发来的指令，目前只支持"绑定"指令
    """

    if request.method == 'GET':
        my_wechat = Wechat()
        is_valid = my_wechat.check_signature(signature=request.args['signature'],
                                             timestamp=request.args['timestamp'],
                                             nonce=request.args['nonce'])
        echostr = request.args['echostr']
        if is_valid:
            return echostr
        else:
            return "error"

    elif request.method == 'POST':
        my_wechat = Wechat()
        is_valid = my_wechat.check_signature(signature=request.args['signature'],
                                             timestamp=request.args['timestamp'],
                                             nonce=request.args['nonce'])
        if is_valid:
            data = Wechat.decrypt(xml=request.stream.read(), msg_signature=request.args['msg_signature'],
                                  timestamp=request.args['timestamp'], nonce=request.args['nonce'])
            if data is not None:
                my_wechat.xml_to_self(data)
                if my_wechat.message.Content == u'绑定':
                    bind_user = User.query.filter_by(open_id=request.args['openid']).first()
                    if bind_user:
                        return Wechat.prepare_to_response(my_wechat.message.FromUserName,
                                                          my_wechat.message.ToUserName,
                                                          my_wechat.message.CreateTime,
                                                          my_wechat.message.MsgType,
                                                          u'您已绑定eHPC帐号，绑定帐号为%s！<a href="%s">点此解绑</a>' %
                                                          (bind_user.username, url_for('wechat.unbind',
                                                                                       open_id=request.args['openid'],
                                                                                       _external=True)),
                                                          request.args['nonce'])
                    else:
                        return Wechat.prepare_to_response(my_wechat.message.FromUserName,
                                                          my_wechat.message.ToUserName,
                                                          my_wechat.message.CreateTime,
                                                          my_wechat.message.MsgType,
                                                          u'您尚未绑定eHPC帐号，请先绑定！<a href="%s">点此绑定</a>' %
                                                          url_for('wechat.bind', open_id=request.args['openid'],
                                                                  _external=True),
                                                          request.args['nonce'])

            else:
                return "error"
        else:
            return "error"


@wechat.route('/bind/<open_id>/')
@login_required
def bind(open_id):
    bind_user = User.query.filter_by(open_id=open_id).first()
    if bind_user:
        return render_template('wechat/result.html', text=u"此微信帐号已绑定eHPC帐号！")
    else:
        current_user.open_id = open_id
        db.session.commit()
        return render_template('wechat/result.html', text=u"绑定成功！")


@wechat.route('/unbind/<open_id>/')
def unbind(open_id):
    unbind_user = User.query.filter_by(open_id=open_id).first()
    if unbind_user:
        unbind_user.open_id = None
        db.session.commit()
        return render_template('wechat/result.html', text=u"解绑成功！")
    else:
        return render_template('wechat/result.html', text=u"此微信号未绑定eHPC帐号！")


@wechat.route('/qr-code/', methods=['GET', 'POST'])
@login_required
def qr_code():
    """get方法用于处理用户使用二维码扫描加入课程的逻辑
       post方法用于生成课程二维码并返回前端
    """
    if request.method == 'GET':
        qrcode_img = QRcode.query.filter_by(id=request.args['id']).first_or_404()
        if qrcode_img.end_time > datetime.now():
            if current_user in qrcode_img.course.users:
                return render_template('wechat/result.html', text=u'请勿重复加入课程！')
            qrcode_img.course.users.append(current_user)
            qrcode_img.course.studentNum += 1
            db.session.commit()
            return render_template('wechat/result.html', text=u'加入成功！')
        else:
            return render_template('wechat/result.html', text=u'二维码已失效！')

    if request.method == 'POST':
        if current_user.permissions != 2:
            return redirect(url_for('main.index'))

        cur_course = Course.query.filter_by(id=request.form['course_id']).first_or_404()
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_M,
            box_size=10,
            border=4
        )

        if cur_course.qrcode is None:
            new_qrcode = QRcode(end_time=datetime.now() + timedelta(days=180), course_id=cur_course.id)
            db.session.add(new_qrcode)
            db.session.commit()
            qr.add_data(url_for('wechat.qr_code', id=new_qrcode.id, _external=True))
        else:
            cur_course.qrcode.end_time = datetime.now() + timedelta(days=180)
            db.session.commit()
            qr.add_data(url_for('wechat.qr_code', id=cur_course.qrcode.id, _external=True))

        qr.make(fit=True)
        img = qr.make_image()
        img.save(os.path.join(current_app.config['QRCODE_FOLDER'], 'qr-code-course%s.png' % request.form['course_id']))
        return jsonify(status='success',
                       img_path=url_for('static',
                                        filename='images/QRcode/qr-code-course%s.png' % request.form['course_id']))
