#! /usr/bin/env python
# -*- coding: utf-8 -*-

from . import filter_blueprint
import json
from flask import Markup


@filter_blueprint.app_template_filter('get_json_value')
def get_json_value(text, key):
    return json.loads(text)[key]


@filter_blueprint.app_template_filter('get_question_content')
def get_question_content(question):
    if question.type == 0 or question.type == 1 or question.type == 2:
        return json.loads(question.content)['title']
    elif question.type == 3:
        return '____'.join(question.content.split('*')[0::2])
    else:
        return question.content


@filter_blueprint.app_template_filter('get_question_solution')
def get_question_solution(question):
    if question.type == 3:
        return ';'.join(question.content.split('*')[1::2])
    if question.type == 4:
        return u'正确' if question.solution == '1' else u'错误'
    else:
        return question.solution


@filter_blueprint.app_template_filter('get_question_type')
def get_question_type(question):
    dic = {0: u'单选题', 1: u'多选题', 2: u'不定项选择题', 3: u'填空题', 4: u'判断题', 5: u'问答题'}
    return dic[question.type]


@filter_blueprint.app_template_filter('get_question_id')
def get_question_id(question):
    dic = {0: u'choice', 1: u'choice', 2: u'choice', 3: u'fill', 4: u'judge', 5: u'essay'}
    return dic[question.type]


@filter_blueprint.app_template_filter('get_apply_status')
def get_apply_status(status):
    dic = {0: u'待定', 1: u'已同意', 2: u'已拒绝', 3: u'已退出'}
    return dic[status]


@filter_blueprint.app_template_filter('get_sc_center')
def get_sc_center(sc_id):
    dic = {0: u'国家超级计算广州中心', 1: u'国家超级计算长沙中心', 2: u'中科院级计算中心', 3: u'国家超级计算上海中心'}
    return dic[sc_id]
