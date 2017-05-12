#! /usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Blueprint
machine_apply = Blueprint('machine_apply', __name__)
from . import views
