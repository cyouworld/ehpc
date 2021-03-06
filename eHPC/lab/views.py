#! /usr/bin/env python
# -*- coding: utf-8 -*-

import random
import string
from datetime import datetime
from time import sleep

import requests
from flask import render_template, request, jsonify, abort, current_app, url_for
from flask_babel import gettext
from flask_login import login_required, current_user
from sqlalchemy import exc

from eHPC.util.new_api import submit_code_new
from . import lab
from .lab_util import get_cur_progress, increase_progress, get_cur_vnc_progress, increase_vnc_progress
from .vnc_util import is_token_unique, create_new_image, start_vnc_server, start_ssh_server, stop_image, start_image
from .. import db
from ..models import Challenge, Knowledge, VNCKnowledge, VNCTask, DockerImage, DockerHolder


@lab.route('/')
@login_required
def index():
    knowledges = Knowledge.query.order_by(Knowledge.lab_id.asc())
    vnc_knowledges = VNCKnowledge.query.order_by(VNCKnowledge.lab_id.asc())
    # 记录当前用户在每个knowledge上的进度百分比
    if current_user.is_authenticated:
        all_knowledges = []
        for k in knowledges:
            pro = current_user.progresses.filter_by(knowledge_id=k.id).first()
            k.cur_level = pro.cur_progress if pro else 0
            k.all_levels = k.challenges.count()
            k.percentage = "{0:.0f}%".format(100.0 * k.cur_level / k.all_levels) if k.all_levels >= 1 else "100%"
            all_knowledges.append(k)
        for k in vnc_knowledges:
            pro = current_user.vnc_progresses.filter_by(vnc_knowledge_id=k.id).first()
            k.cur_vnc_level = pro.have_done if pro else 0
            k.all_vnc_levels = k.vnc_tasks.count()
            k.percentage = "{0:.0f}%".format(100.0 * k.cur_vnc_level / k.all_vnc_levels) if k.all_vnc_levels >= 1 else "100%"
            bigger = 1  # 用于判断当前VNC实验序号是否比all_knowledges里面所有的序号都大
            for idx in range(len(all_knowledges)):
                if all_knowledges[idx].lab_id > k.lab_id:
                    bigger = 0
                    all_knowledges.insert(idx, k)
                    break
            if bigger:
                # 若当前VNC实验序号比all_knowledges里面所有的序号都大，则直接在最后插入
                all_knowledges.append(k)
    return render_template('lab/index.html',
                           title=gettext('Labs'),
                           all_knowledges=all_knowledges)


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
                               cur_challenge=cur_challenge,
                               kid=kid,
                               next_progress=cur_progress+1,
                               challenges_count=challenges_count)

    elif request.method == 'POST':
        if request.form['op'] == 'run':

            k_num = request.form['k_num']

            uid = current_user.id
            pid = str(kid) + '_' + str(k_num)

            source_code = request.form['code']
            cpu_number = request.form['cpu_number']
            ifEvaluate = request.form['ifEvaluate']

            cur_challenge = Challenge.query.filter_by(knowledgeId=kid).filter_by(knowledgeNum=k_num).first()

            language = cur_challenge.language

            if language == "openmp" :
                cpu_number_per_task = cpu_number
                task_number = 1
            elif language == "mpi" :
                task_number = cpu_number
                cpu_number_per_task = 1

            is_success = [False]

            result = submit_code_new(pid=pid, uid=uid, source_code=source_code, task_number=task_number,
                                     cpu_number_per_task=cpu_number_per_task, language=language, ifEvaluate=ifEvaluate, is_success=is_success)

            # 代码成功通过编译, 则认为已完成该知识点学习
            if is_success[0]:
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
                               all_tasks=all_tasks,
                               title=u'当前学习进度')


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
            except ValueError:
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
    protocol = request.form.get('protocol', None)
    if protocol is None:
        return jsonify(status='fail', msg=u"参数丢失")

    while True:
        token = ''.join(random.sample(string.ascii_letters + string.digits, 32))
        if not is_token_unique(token):
            continue
        break

    try:
        docker_image = DockerImage(vnc_password=''.join(random.sample(string.ascii_letters + string.digits, 8)),
                                   ssh_password=current_app.config['SSH_PASSWORD'],
                                   name='image_' + str(current_user.id),
                                   user_id=current_user.id)
        db.session.add(docker_image)
        db.session.commit()

        result, message, docker_image = create_new_image(docker_image)
        if result is False:
            return jsonify(status='fail', msg=message)
        if docker_image.docker_holder.using_container_count >= DockerHolder.MAX_RUNNING_COUNT:
            stop_image(docker_image)

    except exc.IntegrityError as e:
        db.session.rollback()
        docker_image = DockerImage.query.filter_by(user_id=current_user.id).first()

    if docker_image.docker_holder.using_container_count >= DockerHolder.MAX_RUNNING_COUNT:
        return jsonify(status='fail', msg=u'目前使用人数过多，请稍后再试')

    if docker_image.is_running is False:
        status, msg = start_image(docker_image)
        if status is False:
            return jsonify(status='fail', msg=msg)

    if protocol == 'vnc':
        if docker_image.is_vnc_running is False:
            result, message = start_vnc_server(docker_image)
            if result is False:
                return jsonify(status='fail', msg=message)
    elif protocol == 'ssh':
        if docker_image.is_ssh_running is False:
            result, message = start_ssh_server(docker_image)
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
            sleep(3)
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
        protocol = request.form.get('protocol', None)

        if protocol is None:
            print ('protocol is None')
            return jsonify(status='fail')

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
                       image_port=str(cur_image.port) if protocol == "vnc" else str(cur_image.port+1000),
                       image_pw=cur_image.vnc_password if protocol == "vnc" else cur_image.ssh_password)

    elif op == 'update_information':
        tunnel_id = request.form.get('tunnel_id', None)
        image_id = request.form.get('image_id', None)

        if tunnel_id is None or image_id is None:
            return jsonify(status='fail')

        cur_image = DockerImage.query.filter_by(id=image_id).first()

        if cur_image is None:
            return jsonify(status='fail')

        if cur_image.tunnel_id is None:
            cur_image.docker_holder.using_container_count += 1

        cur_image.tunnel_id = tunnel_id
        cur_image.status = DockerImage.CONNECTED
        cur_image.last_connect_time = datetime.now()

        db.session.commit()
        return jsonify(status='success')

    elif op == 'reset_information':
        image_id = request.form.get('image_id', None)
        tunnel_id = request.form.get('tunnel_id', None)

        if image_id is None or tunnel_id is None:
            return jsonify(status='fail')

        cur_image = DockerImage.query.filter_by(id=image_id).first()
        if cur_image is None:
            return jsonify(status='fail')

        if cur_image.tunnel_id == tunnel_id:
            stop_image(cur_image)

            cur_image.tunnel_id = None
            cur_image.status = DockerImage.DISCONNECTED
            cur_image.token = None
            cur_image.docker_holder.using_container_count -= 1
            db.session.commit()

        return jsonify(status='success')















