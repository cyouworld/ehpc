#! /usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: xuezaigds@gmail.com
# @Last Modified time: 2016-09-19 14:30:26
from flask import Blueprint
admin = Blueprint('admin', __name__)
from . import views, system_views, teacher_views, hpc_views
