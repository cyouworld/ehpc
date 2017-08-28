#! /usr/bin/env python
# -*- coding: utf-8 -*-

from . import filter_blueprint
from ..models import MachineApply, MachineAccount
from sqlalchemy import *
from .. import db

@filter_blueprint.app_template_filter('not_applied')
def not_applied(user_account, sc_center):
    """ 判断用户是否已有某个超算中心的账号.
    """
    for a in user_account:
        if a.sc_center == sc_center:
            return False
    return True
