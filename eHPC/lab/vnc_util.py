#! /usr/bin/env python
# -*- coding: utf-8 -*-
import requests
from datetime import datetime

from .. import db
from ..models import DockerImage, DockerHolder
from flask_login import current_user
import random, string


def is_token_unique(token):
    docker_image = DockerImage.query.filter_by(token=token).first()
    return docker_image is None


def is_reconnection():
    docker_image = current_user.docker_image
    if docker_image is not None and docker_image.status == DockerImage.CONNECTED:
        return True, docker_image
    return False, None


def create_new_image():
    new_image = DockerImage(password=''.join(random.sample(string.ascii_letters + string.digits, 8)),
                            name='image_' + str(current_user.id))
    new_image.user = current_user

    db.session.add(new_image)
    db.session.commit()

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
                                    "image_port": str(new_image.port),
                                    "image_password": new_image.password,
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
            docker_image.is_running = True
            db.session.commit()
            return True, "success"
        else:
            print result['message']
            return False, u'启动远程桌面服务失败'




