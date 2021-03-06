#! /usr/bin/env python
# -*- coding: utf-8 -*-

from . import filter_blueprint
from ..models import Course, User, PaperQuestion, Homework, HomeworkUpload, HomeworkScore, SubmitProgram
from sqlalchemy import *
from .. import db
import json
from datetime import datetime
from flask import Markup


@filter_blueprint.app_template_filter('is_join_course')
def is_join_course(user_id, course_id):
    """ Check if one use join in a course or not.
    """
    cur_course = Course.query.filter_by(id=course_id).first()
    cur_user = User.query.filter_by(id=user_id).first()
    if cur_user in cur_course.users:
        return True
    else:
        return False


@filter_blueprint.app_template_filter('get_icon_class')
def get_icon_class(resource_type="audio"):
    type_class_dict = dict()
    type_class_dict['audio'] = "es-icon es-icon-audioclass"         # 音频资料
    type_class_dict['video'] = "es-icon es-icon-videoclass"         # 视频资料
    type_class_dict['ppt'] = "es-icon es-icon-description"          # PPT,PDF 资料
    type_class_dict['pdf'] = "es-icon es-icon-description"          # PPT,PDF 资料
    type_class_dict['graphic'] = "es-icon es-icon-graphicclass"     # 图文资料
    return type_class_dict[resource_type]


@filter_blueprint.app_template_filter('get_substring_number')
def get_substring_number(string, c):
    return len(string.split(c))


@filter_blueprint.app_template_filter('split_fill')
def split_fill(string):
    temp = string.split('*')[0::2]
    for i in range(len(temp)):
        temp[i] = '<span>' + temp[i] + '</span>'
    return '<input type="text" class="fill-input" style="margin: 0 10px;text-align:center">'.join(temp)


@filter_blueprint.app_template_filter('get_fill_solution_len')
def get_fill_solution_len(string):
    temp = json.loads(string)
    result = []
    for i in range(temp['len']):
        result.append(str(len(temp[str(i)])))
    return ';'.join(result)


@filter_blueprint.app_template_filter('get_total_point')
def get_total_point(paper_question, q_type=-1):
    result = 0
    if q_type == -1:
        for pq in paper_question:
            result += pq.point
    else:
        for pq in paper_question:
            if pq.questions.type == q_type:
                result += pq.point
    return result


@filter_blueprint.app_template_filter('get_question_number')
def get_question_number(paper_question, q_type=-1):
    result = 0
    if q_type == -1:
        for _ in paper_question:
            result += 1
    else:
        for pq in paper_question:
            if pq.questions.type == q_type:
                result += 1
    return result


@filter_blueprint.app_template_filter('sort_materials')
def sort_materials(materials):
    new_materials = []
    for m in materials:
        new_materials.append(m)
    for i in range(0, materials.count()):
        for j in range(i+1, materials.count()):
            if new_materials[i].name.lower() > new_materials[j].name.lower():
                tmp = new_materials[i]
                new_materials[i] = new_materials[j]
                new_materials[j] = tmp
    return new_materials


@filter_blueprint.app_template_filter('unite_time_format')
def unite_time_format(course_time):
    return course_time.strftime('%Y-%m-%d %H:%M') if course_time else ""


@filter_blueprint.app_template_filter('check_upload')
def check_upload(user, homework_id):
    homework = Homework.query.filter_by(id=homework_id).first_or_404()
    his_upload = HomeworkUpload.query.filter_by(user_id=user.id, homework_id=homework_id).order_by(HomeworkUpload.submit_time.asc()).first()
    if not his_upload:
        return 2
    else:
        if his_upload.submit_time > homework.deadline:
            return 1
        else:
            return 0


@filter_blueprint.app_template_filter('get_score')
def get_score(user, homework_id):
    homework_score = HomeworkScore.query.filter_by(user_id=user.id, homework_id=homework_id).first()
    if homework_score:
        return homework_score.score
    else:
        return ""


@filter_blueprint.app_template_filter('get_comment')
def get_comment(user, homework_id):
    homework_score = HomeworkScore.query.filter_by(user_id=user.id, homework_id=homework_id).first()
    if homework_score:
        return homework_score.comment
    else:
        return ""


@filter_blueprint.app_template_filter('homework_uploaded')
def homework_uploaded(homework_id, user_id):
    curr_user = User.query.filter_by(id=user_id).first_or_404()
    curr_homework = Homework.query.filter_by(id=homework_id).first_or_404()
    if curr_homework.h_type == 0:
        curr_user_upload = curr_user.homeworks.filter_by(homework_id=homework_id).first()
        if curr_user_upload:
            return True
        else:
            return False
    else:
        for p in curr_homework.program:
            his_submit = SubmitProgram.query.filter_by(pid=p.id, uid=user_id).all()
            if len(his_submit) == 0:
                return False
        return True


@filter_blueprint.app_template_filter('get_course_name')
def get_course_name(c_id):
    curr_course = Course.query.filter_by(id=c_id).first()
    if curr_course:
        return curr_course.title
    else:
        return ""


@filter_blueprint.app_template_filter('is_checked')
def is_checked(p_id, h_id):
    curr_homework = Homework.query.filter_by(id=h_id).first_or_404()
    found = curr_homework.program.filter_by(id=p_id).first()
    if found:
        return True
    else:
        return False


@filter_blueprint.app_template_filter('has_score')
def has_score(u_id, h_id):
    homework_score = HomeworkScore.query.filter_by(user_id=u_id, homework_id=h_id).first()
    if homework_score:
        return True
    else:
        return False


@filter_blueprint.app_template_filter('distinct_submits')
def distinct_submits(program, c_id):
    #   用于筛选每道编程题的submits记录，每位学生只显示最近的一次提交
    all_submits = SubmitProgram.query.filter_by(pid=program.id).order_by(SubmitProgram.submit_time.desc())
    submits = []
    curr_course = Course.query.filter_by(id=c_id).first_or_404()
    user_ids = []
    for u in curr_course.users:
        user_ids.append(u.id)
    for u_id in user_ids:
        curr_submit = all_submits.filter_by(uid=u_id).first()
        if curr_submit:
            submits.append(curr_submit)
    return submits
