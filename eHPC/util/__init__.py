#! /usr/bin/env python
# -*- coding: utf-8 -*-
from flask import Blueprint
filter_blueprint = Blueprint('filters', __name__)

# Register all the filter.
from . import course_filter, time_process, text_process, user_filter, group_filter, problem_filter, admin_filter, case_filter, statistics_filter, machine_apply_filter
