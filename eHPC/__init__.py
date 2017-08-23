#! /usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: xuezaigds@gmail.com
# @Last Modified time: 2016-09-19 14:11:20

from flask import Flask
from flask_mail import Mail
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
from config import config
from datetime import timedelta
import geoip2.database


mail = Mail()
db = SQLAlchemy()
login_manager = LoginManager()
login_manager.session_protection = 'strong'
login_manager.login_view = 'user.signin'


def create_app(config_name):
    app = Flask(__name__)
    app.config.from_object(config[config_name])
    config[config_name].init_app(app)

    mail.init_app(app)
    db.init_app(app)
    login_manager.init_app(app)

    import logging
    app.email_logger = logging.getLogger('email')
    app.email_logger.setLevel(logging.INFO)
    file_handler = logging.FileHandler('app_logs/email.log')
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(logging.Formatter('[%(asctime)s] %(message)s'))
    app.email_logger.addHandler(file_handler)

    app.geoip_reader = geoip2.database.Reader('GeoLite2-City.mmdb')

    # Register all the filter.
    from .util import filter_blueprint
    app.register_blueprint(filter_blueprint)

    from .main import main as main_blueprint
    app.register_blueprint(main_blueprint)
    from .user import user as user_blueprint
    app.register_blueprint(user_blueprint, url_prefix='/user')
    from .admin import admin as admin_blueprint
    app.register_blueprint(admin_blueprint, url_prefix='/admin')
    from .course import course as course_blueprint
    app.register_blueprint(course_blueprint, url_prefix='/course')
    from .group import group as group_blueprint
    app.register_blueprint(group_blueprint, url_prefix='/group')
    from .problem import problem as problems_blueprint
    app.register_blueprint(problems_blueprint, url_prefix='/problems')
    from .article import article as article_blueprint
    app.register_blueprint(article_blueprint, url_prefix='/article')

    from .lab import lab as lab_blueprint
    app.register_blueprint(lab_blueprint, url_prefix='/lab')
    from .api import api as api_blueprint
    app.register_blueprint(api_blueprint, url_prefix='/api')
    from .case import case as case_blueprint
    app.register_blueprint(case_blueprint, url_prefix='/case')
    from .markdown_files import markdown_files as markdown_files_blueprint
    app.register_blueprint(markdown_files_blueprint, url_prefix='/markdown_files')

    from .wechat import wechat as wechat_blueprint
    app.register_blueprint(wechat_blueprint, url_prefix='/wechat')

    from .machine_apply import machine_apply as machine_apply_blueprint
    app.register_blueprint(machine_apply_blueprint, url_prefix='/machine_apply')

    return app
