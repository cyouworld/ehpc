#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import xlsxwriter
import xlrd

from flask import current_app
from ..models import HomeworkScore


def get_member_xlsx(members, required_field, course_id):
    uri = os.path.join(current_app.config['DOWNLOAD_FOLDER'], 'course%d.xlsx' % course_id)
    workbook = xlsxwriter.Workbook(uri)
    worksheet = workbook.add_worksheet()
    cnt = 0
    for f in required_field:
        worksheet.write(0, cnt, f)
        cnt += 1
    row = 1
    for m in members:
        cnt = 0
        if u"姓名" in required_field:
            worksheet.write(row, cnt, m.name)
            cnt += 1
        if u"学号" in required_field:
            worksheet.write(row, cnt, m.student_id)
            cnt += 1
        if u"性别" in required_field:
            if m.gender:
                worksheet.write(row, cnt, u'女')
            else:
                worksheet.write(row, cnt, u'男')
            cnt += 1
        if u"电话" in required_field:
            worksheet.write(row, cnt, m.phone)
            cnt += 1
        if u"邮箱" in required_field:
            worksheet.write(row, cnt, m.email)
            cnt += 1
        row += 1

    workbook.close()
    return uri


def get_score_xlsx(all_users, course_id, homework_id):
    uri = os.path.join(current_app.config['HOMEWORK_UPLOAD_FOLDER'], "course_%d" % course_id, "homework_%d" % homework_id, 'score.xlsx')
    workbook = xlsxwriter.Workbook(uri)
    worksheet = workbook.add_worksheet()
    worksheet.write(0, 0, u'学号')
    worksheet.write(0, 1, u'姓名')
    worksheet.write(0, 2, u'分数')
    worksheet.write(0, 3, u'评语')
    row = 1
    for u in all_users:
        cur_stu_score = HomeworkScore.query.filter_by(user_id=u.id, homework_id=homework_id).first()
        worksheet.write(row, 0, u.student_id)
        worksheet.write(row, 1, u.name)
        if cur_stu_score:
            worksheet.write(row, 2, cur_stu_score.score)
            worksheet.write(row, 3, cur_stu_score.comment)
        else:
            worksheet.write(row, 2, u'')
            worksheet.write(row, 3, u'')
        row += 1

    workbook.close()
    return uri


def get_allscore_xlsx(all_users, all_homework, course_id):
    uri = os.path.join(current_app.config['HOMEWORK_UPLOAD_FOLDER'], "course_%d" % course_id, 'score.xlsx')
    workbook = xlsxwriter.Workbook(uri)
    worksheet = workbook.add_worksheet()
    worksheet.write(0, 0, u'学号')
    worksheet.write(0, 1, u'姓名')
    col = 2
    for h in all_homework:
        worksheet.write(0, col, u'作业%d' % (col-1))
        col += 1
    row = 1
    for u in all_users:
        col = 2
        for h in all_homework:
            cur_stu_score = HomeworkScore.query.filter_by(user_id=u.id, homework_id=h.id).first()
            worksheet.write(row, 0, u.student_id)
            worksheet.write(row, 1, u.name)
            if cur_stu_score:
                worksheet.write(row, col, cur_stu_score.score)
            else:
                worksheet.write(row, col, u'')
            col += 1
        row += 1

    workbook.close()
    return uri


def get_not_uploaded_xlsx(all_users, course_id, homework_id):
    uri = os.path.join(current_app.config['HOMEWORK_UPLOAD_FOLDER'], "course_%d" % course_id, "homework_%d" % homework_id, 'not_uploaded.xlsx')
    workbook = xlsxwriter.Workbook(uri)
    worksheet = workbook.add_worksheet()
    worksheet.write(0, 0, u'学号')
    worksheet.write(0, 1, u'姓名')
    worksheet.write(0, 2, u'性别')
    worksheet.write(0, 3, u'手机')
    worksheet.write(0, 4, u'邮箱')
    row = 1
    for u in all_users:
        worksheet.write(row, 0, u.student_id)
        worksheet.write(row, 1, u.name)
        if u.gender:
            worksheet.write(row, 2, u'女')
        else:
            worksheet.write(row, 2, u'男')
        worksheet.write(row, 3, u.phone)
        worksheet.write(row, 4, u.email)
        row += 1

    workbook.close()
    return uri
