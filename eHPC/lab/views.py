#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
from datetime import datetime

from flask import render_template, request, jsonify, abort, current_app, url_for
from flask_babel import gettext
from flask_login import login_required, current_user

from eHPC.util.code_process import ehpc_client, submit_code
from . import lab
from ..models import Challenge, Knowledge, VNCKnowledge, VNCTask, DockerHolder, DockerImage

from .vnc_util import is_token_unique, is_reconnection, create_new_image, start_vnc_server
from .lab_util import get_cur_progress, increase_progress, get_cur_vnc_progress, increase_vnc_progress
from config import TH2_MY_PATH
import random, string
import requests, threading
from .. import db


@lab.route('/')
@login_required
def index():
    knowledges = Knowledge.query.all()
    vnc_knowledges = VNCKnowledge.query.all()
    # 记录当前用户在每个knowledge上的进度百分比
    if current_user.is_authenticated:
        for k in knowledges:
            pro = current_user.progresses.filter_by(knowledge_id=k.id).first()
            k.cur_level = pro.cur_progress if pro else 0
            k.all_levels = k.challenges.count()
            k.percentage = "{0:.0f}%".format(100.0 * k.cur_level / k.all_levels) if k.all_levels >= 1 else "100%"
        for k in vnc_knowledges:
            pro = current_user.vnc_progresses.filter_by(vnc_knowledge_id=k.id).first()
            k.cur_vnc_level = pro.have_done if pro else 0
            k.all_vnc_levels = k.vnc_tasks.count()
            k.percentage = "{0:.0f}%".format(100.0 * k.cur_vnc_level / k.all_vnc_levels) if k.all_vnc_levels >= 1 else "100%"
    return render_template('lab/index.html',
                           title=gettext('Labs'),
                           knowledges=knowledges,
                           vnc_knowledges=vnc_knowledges)


@lab.route('/detail/<int:kid>/')
@login_required
def detail(kid):
    cur_knowledge = Knowledge.query.filter_by(id=kid).first_or_404()
    cur_level = get_cur_progress(kid)

    if request.method == 'GET':
        return render_template("lab/detail.html",
                               title=cur_knowledge.title,
                               knowledge=cur_knowledge,
                               cur_level=cur_level)


@lab.route('/knowledge/<int:kid>/', methods=['POST', 'GET'])
@login_required
def knowledge(kid):
    """ 根据用户进度记录以及请求中 progress 字段来决定给用户返回哪个 challenge.

    cur_progress: 用户请求的任务进度, 如果请求中没有提供, 则返回下一个需要完成的任务的编号
    """
    cur_knowledge = Knowledge.query.filter_by(id=kid).first_or_404()
    challenges_count = cur_knowledge.challenges.count()

    if request.method == 'GET':
        cur_progress = get_cur_progress(kid)

        try:
            request_progress = int(request.args.get('progress', None))
        except ValueError:
            return abort(404)
        except TypeError:
            request_progress = cur_progress

        if request_progress < 0:
            return abort(404)
        if 0 < request_progress <= cur_progress+1:
            cur_progress = request_progress
        else:
            # 前面还有任务没有完成, 不能直接到请求的任务页面, 这里返回一个简单的提示页面
            return render_template("lab/out_progress.html",
                                   title=u"前面任务还没完成",
                                   next_progress=cur_progress+1,
                                   kid=kid)

        # 获取当前技能中顺序为 cur_progress 的 challenge, 然后获取相应的详细内容
        cur_challenge = Challenge.query.filter_by(knowledgeId=kid).filter_by(knowledgeNum=cur_progress).first()
        if cur_challenge is None:
            return render_template('lab/finish_progress.html',
                                   title=u"学习完成",
                                   kid=kid,
                                   challenges=cur_knowledge.challenges.all(),
                                   cur_level=cur_progress)

        # challenge 可能没有相应的 material 存在, cur_material 对应为空。
        return render_template('lab/knowledge.html',
                               title=cur_challenge.title,
                               c_content=cur_challenge.content,
                               cur_material=cur_challenge.material,
                               kid=kid,
                               next_progress=cur_progress+1,
                               challenges_count=challenges_count)

    elif request.method == 'POST':
        if request.form['op'] == 'run':

            op = request.form['job_op']
            job_id = request.form['job_id']
            k_num = request.form['k_num']

            uid = current_user.id
            pid = str(kid) + '_' + str(k_num)

            source_code = ''

            if op == '1':
                source_code = request.form['code']

            cur_challenge = Challenge.query.filter_by(knowledgeId=kid).filter_by(knowledgeNum=k_num).first()

            task_number = cur_challenge.task_number
            cpu_number_per_task = cur_challenge.cpu_number_per_task
            node_number = cur_challenge.node_number
            language = cur_challenge.language

            compile_success = [True]

            result = submit_code(pid=pid, uid=uid, source_code=source_code,
                                 task_number=task_number, cpu_number_per_task=cpu_number_per_task, node_number=node_number,
                                 language=language, op=op, jobid=job_id, compile_success=compile_success)


            # 代码成功通过编译, 则认为已完成该知识点学习
            if compile_success[0]:
                increase_progress(kid=kid, k_num=k_num, challenges_count=challenges_count)

            return result
        elif request.form['op'] == 'get_source_code':
            cur_challenge = Challenge.query.filter_by(knowledgeId=kid).filter_by(knowledgeNum=request.form['k_num']).first()
            return jsonify(source_code=cur_challenge.source_code, status='success')
        elif request.form['op'] == 'get_default_code':
            cur_challenge = Challenge.query.filter_by(knowledgeId=kid).filter_by(knowledgeNum=request.form['k_num']).first()
            return jsonify(default_code=cur_challenge.default_code, status='success')


@lab.route('/my_progress/<int:kid>/')
@login_required
def my_progress(kid):
    cur_knowledge = Knowledge.query.filter_by(id=kid).first_or_404()
    cur_level = get_cur_progress(kid)
    all_challenges = cur_knowledge.challenges.all()
    all_challenges.sort(key=lambda k: k.knowledgeNum)
    return render_template('lab/widget_show_progress.html',
                           kid=kid,
                           title=cur_knowledge.title,
                           challenges=all_challenges,
                           cur_level=cur_level)


@lab.route('/vnc/tasks_list/<int:vnc_knowledge_id>/')
@login_required
def tasks_list(vnc_knowledge_id):
    cur_vnc_knowledge = VNCKnowledge.query.filter_by(id=vnc_knowledge_id).first_or_404()
    cur_vnc_level = get_cur_vnc_progress(vnc_knowledge_id)
    all_tasks = cur_vnc_knowledge.vnc_tasks.order_by(VNCTask.vnc_task_num).all()

    if request.method == 'GET':
        return render_template('lab/vnc_tasks_lists.html',
                               cur_vnc_knowledge=cur_vnc_knowledge,
                               cur_vnc_level=cur_vnc_level,
                               all_tasks=all_tasks)


@lab.route('/vnc/task/<int:vnc_knowledge_id>/', methods=['GET', 'POST'])
@login_required
def vnc_task(vnc_knowledge_id):
    if request.method == 'GET':
        cur_vnc_knowledge = VNCKnowledge.query.filter_by(id=vnc_knowledge_id).first_or_404()
        vnc_tasks_count = cur_vnc_knowledge.vnc_tasks.count()

        cur_vnc_progress = get_cur_vnc_progress(vnc_knowledge_id)   # 用户已完成的最大task序号
        response_vnc_task_num = cur_vnc_progress + 1
        try:
            request_vnc_task_number = int(request.args.get('request_vnc_task_number', None))
        except ValueError:
            return abort(404)

        except TypeError:
            request_vnc_task_number = cur_vnc_progress

        if request_vnc_task_number < 0:
            return abort(404)
        if 0 < request_vnc_task_number <= cur_vnc_progress + 1:  # 正确的请求范围，即1至用户已完成的最大task序号加1
            response_vnc_task_num = request_vnc_task_number
        elif cur_vnc_progress + 1 < request_vnc_task_number <= vnc_tasks_count + 1:  # 合法但不允许访问的范围，即大于用户已完成的最大task序号加1，至总任务数加1
            return render_template('lab/vnc_out_of_progress.html',
                                   title=u'前面任务还没完成',
                                   next_vnc_task_num=cur_vnc_progress + 1,
                                   vnc_knowledge_id=vnc_knowledge_id)
        else:   # 超过总任务数加1，认为是非法参数
            abort(404)

        if response_vnc_task_num == vnc_tasks_count + 1:
            return render_template('lab/vnc_finish_all_tasks.html',
                                   title=u'学习完成',
                                   vnc_knowledge_id=vnc_knowledge_id)

        response_vnc_task = VNCTask.query.filter_by(vnc_knowledge_id=vnc_knowledge_id).filter_by(vnc_task_num=response_vnc_task_num).first()
        if response_vnc_task is not None:
            return render_template('lab/vnc.html',
                                   title=gettext('vnc'),
                                   response_vnc_task=response_vnc_task,
                                   vnc_tasks_count=vnc_tasks_count,
                                   vnc_knowledge_id=cur_vnc_knowledge.id)
        else:
            abort(404)
    elif request.method == 'POST':
        op = request.form.get('op', None)

        if op is None:
            return jsonify(status='fail')

        if op == 'get vnc lab progress':
            cur_vnc_knowledge = VNCKnowledge.query.filter_by(id=vnc_knowledge_id).first()

            if cur_vnc_knowledge is None:
                return jsonify(status='fail')

            all_tasks = cur_vnc_knowledge.vnc_tasks.order_by(VNCTask.vnc_task_num).all()
            if all_tasks is None:
                return jsonify(status='fail')

            cur_vnc_level = get_cur_vnc_progress(vnc_knowledge_id)
            return jsonify(status='success', html=render_template('lab/vnc_widget_show_progress.html',
                                                                  cur_vnc_knowledge=cur_vnc_knowledge,
                                                                  cur_vnc_level=cur_vnc_level,
                                                                  all_tasks=all_tasks))
        elif op == 'next task':
            vnc_task_num = request.form.get('vnc_task_num', None)
            if vnc_task_num is None:
                return jsonify(status='fail')

            try:
                vnc_task_num = int(vnc_task_num)
            except TypeError:
                return jsonify(status='fail')

            cur_vnc_knowledge = VNCKnowledge.query.filter_by(id=vnc_knowledge_id).first()
            cur_vnc_progress = current_user.vnc_progresses.filter_by(vnc_knowledge_id=vnc_knowledge_id).first()

            if cur_vnc_knowledge is None or cur_vnc_progress is None:
                return jsonify(status='fail')

            vnc_tasks_count = cur_vnc_knowledge.vnc_tasks.count()
            increase_vnc_progress(vnc_knowledge_id, vnc_task_num, vnc_tasks_count)

            if not 0 < vnc_task_num <= cur_vnc_progress.have_done:
                return jsonify(status='fail')

            if vnc_task_num + 1 <= vnc_tasks_count:
                response_vnc_task = VNCTask.query.filter_by(vnc_knowledge_id=vnc_knowledge_id).filter_by(vnc_task_num=vnc_task_num + 1).first()
                return jsonify(status='success', title=response_vnc_task.title, content=response_vnc_task.content)
            else:
                return jsonify(status='finish', next=url_for('lab.vnc_task',
                                                             vnc_knowledge_id=vnc_knowledge_id,
                                                             request_vnc_task_number=vnc_task_num + 1,
                                                             _external=True))


@lab.route('/vnc/ready/', methods=['POST'])
@login_required
def vnc_ready_to_connect():
    while True:
        token = ''.join(random.sample(string.ascii_letters + string.digits, 32))
        if not is_token_unique(token):
            continue
        break

    result, docker_image = is_reconnection()
    if result is True:
        print("reconnect")
        token = docker_image.token
        docker_image.status = DockerImage.READY_TO_CONNECT
        db.session.commit()
        return jsonify(status='success',
                       token=token,
                       address=docker_image.docker_holder.ip + ':' + str(docker_image.docker_holder.public_port))

    docker_image = current_user.docker_image

    if docker_image is None:
        result, message, docker_image = create_new_image()
        if result is False:
            return jsonify(status='fail', msg=message)
    if docker_image.is_running == 0:
        result, message = start_vnc_server(docker_image)
        if result is False:
            return jsonify(status='fail', msg=message)

    docker_image.token = token
    docker_image.status = DockerImage.READY_TO_CONNECT

    db.session.commit()
    return jsonify(status='success',
                   token=token,
                   address=docker_image.docker_holder.ip + ':' + str(docker_image.docker_holder.public_port))


@lab.route('/vnc/resolution/', methods=['POST'])
@login_required
def vnc_set_resolution():
    width = request.form.get('width', None)
    height = request.form.get('height', None)

    if width is None or height is None:
        return jsonify(status='fail')

    try:
        width = int(width)
        height = int(height)
        if width < 800 or width > 2560 or height < 600 or height > 1440:
            return jsonify(status='fail')
    except ValueError:
        return jsonify(status='fail')
    except TypeError:
        return jsonify(status='fail')

    try:
        req = requests.post('http://%s:%d/server/handler' % (current_user.docker_image.docker_holder.inner_ip,
                                                             current_user.docker_image.docker_holder.inner_port),
                            params={"op": "set_resolution", "image_name": current_user.docker_image.name, "width": width, "height": height}, timeout=10)
        req.raise_for_status()
    except requests.RequestException as e:
        print e
        return jsonify(status='fail')
    else:
        result = req.json()
        if result['status'] == DockerImage.STATUS_SET_RESOLUTION_SUCCESSFULLY:
            current_user.docker_image.status = DockerImage.READY_TO_CONNECT
            current_user.docker_image.docker_holder.running_container_count -= 1
            db.session.commit()
            return jsonify(status='success')
        else:
            return jsonify(status='fail')


@lab.route('/vnc/controller/', methods=['GET', 'POST'])
def db_controller():
    op = request.form.get('op', None)
    if op is None:
        print('op is None')
        return jsonify(status='fail')

    if op == 'find_image':
        token = request.form.get('token', None)

        if token is None:
            print('token is None')
            return jsonify(status='fail')

        if len(token) is not 32:
            print('token length error')
            return jsonify(status='fail')

        cur_image = DockerImage.query.filter_by(token=token, status=DockerImage.READY_TO_CONNECT).first()

        if cur_image is None:
            print('image not found')
            return jsonify(status='fail')

        return jsonify(status='success',
                       docker_holder_ip=cur_image.docker_holder.inner_ip,
                       image_id=str(cur_image.id),
                       image_port=str(cur_image.port),
                       image_pw=cur_image.password)

    elif op == 'update_information':
        tunnel_id = request.form.get('tunnel_id', None)
        image_id = request.form.get('image_id', None)

        if tunnel_id is None or image_id is None:
            return jsonify(status='fail')

        cur_image = DockerImage.query.filter_by(id=image_id).first()

        if cur_image is None:
            return jsonify(status='fail')

        cur_image.tunnel_id = tunnel_id
        cur_image.status = DockerImage.CONNECTED
        cur_image.last_connect_time = datetime.now()

        cur_image.docker_holder.running_container_count += 1

        db.session.commit()
        return jsonify(status='success')

    elif op == 'reset_information':
        tunnel_id = request.form.get('tunnel_id', None)

        if tunnel_id is None:
            return jsonify(status='fail')

        cur_image = DockerImage.query.filter_by(tunnel_id=tunnel_id).first()
        if cur_image is None:
            return jsonify(status='fail')

        cur_image.tunnel_id = None
        cur_image.status = DockerImage.DISCONNECTED
        cur_image.token = None

        cur_image.docker_holder.running_container_count -= 1
        db.session.commit()

        return jsonify(status='success')















