#! /usr/bin/env python
# -*- coding: utf-8 -*-
import requests
from datetime import datetime

from flask import current_app
from .. import db
from ..models import DockerImage, DockerHolder
from flask_login import current_user
import random, string


def is_token_unique(token):
    docker_image = DockerImage.query.filter_by(token=token).first()
    return docker_image is None


# def is_reconnection():
#     docker_image = current_user.docker_image
#     if docker_image is not None and docker_image.status == DockerImage.CONNECTED:
#         return True, docker_image
#     return False, None


def create_new_image(new_image):
    if new_image.docker_holder_id is None:
        db.session.delete(new_image)
        db.session.commit()
        return False, u'创建镜像失败', None

    holder_to_assign = DockerHolder.query.filter_by(id=new_image.docker_holder_id).first()
    if holder_to_assign is None:
        return False, u'创建镜像失败', None

    if holder_to_assign.status == DockerHolder.STOPPED:
        # TODO: 开启超算虚拟机
        pass

    try:
        req = requests.post('http://%s:%d/server/handler' % (holder_to_assign.inner_ip, holder_to_assign.inner_port),
                            params={"op": "create_image",
                                    "image_ssh_port": str(new_image.port + 1000),
                                    "image_port": str(new_image.port),
                                    "image_password": new_image.vnc_password,
                                    "image_name": new_image.name}, timeout=10)
        req.raise_for_status()
    except requests.RequestException as e:
        print e
        new_image.docker_holder.images_count -= 1
        db.session.delete(new_image)
        db.session.commit()
        return False, u'服务器内部错误，请联系管理员', None
    else:
        print req
        result = req.json()
        if result['status'] == DockerImage.STATUS_CREATE_USER_IMAGE_SUCCESSFULLY:
            new_image.create_time = datetime.strptime(result['create_time'], '%Y-%m-%d %H:%M:%S')
            db.session.commit()
            return True, "success", new_image
        else:
            new_image.docker_holder.images_count -= 1
            db.session.delete(new_image)
            db.session.commit()
            print result['message']
            return False, u'创建镜像失败', None


def start_vnc_server(docker_image):
    try:
        req = requests.post('http://%s:%d/server/handler' % (docker_image.docker_holder.inner_ip,
                                                             docker_image.docker_holder.inner_port),
                            params={"op": "start_vnc_server", "image_name": docker_image.name}, timeout=10)
        req.raise_for_status()
    except requests.RequestException as e:
        print e
        return False, u'服务器内部错误，请联系管理员'
    else:
        result = req.json()
        if result['status'] == DockerImage.STATUS_START_VNC_SERVER_SUCCESSFULLY:
            docker_image.is_vnc_running = True
            db.session.commit()
            return True, "success"
        else:
            docker_image.is_vnc_running = False
            db.session.commit()
            print result['message']
            return False, u'启动远程桌面服务失败'


def start_ssh_server(docker_image):
    try:
        req = requests.post('http://%s:%d/server/handler' % (docker_image.docker_holder.inner_ip,
                                                             docker_image.docker_holder.inner_port),
                            params={"op": "start_ssh_server", "image_name": docker_image.name}, timeout=10)
        req.raise_for_status()
    except requests.RequestException as e:
        print e
        return False, u'服务器内部错误，请联系管理员'
    else:
        result = req.json()
        if result['status'] == DockerImage.STATUS_START_SSH_SERVER_SUCCESSFULLY:
            docker_image.is_ssh_running = True
            db.session.commit()
            return True, "success"
        else:
            docker_image.is_ssh_running = False
            db.session.commit()
            print result['message']
            return False, u'启动SSH服务失败'

