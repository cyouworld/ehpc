#! /usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: xuezaigds@gmail.com
# @Last Modified time: 2017-03-21 20:49:16
import os
basedir = os.path.abspath(os.path.dirname(__file__))

"""
从环境变量中读取超算相关的接口配置

TH2_BASE_URL: 基本的请求地址
TH2_LOGIN_UR: 表示请求功能的地址
TH2_ASYNC_URL: 异步获取功能的地址
TH2_ASYNC_FIRST_WAIT_TIME: 首次转到异步获取的等待时间
TH2_ASYNC_WAIT_TIME: 异步获取的等待时间
TH2_USERNAME: 天河账户名
TH2_PASSWORD: 天河账户密码
TH2_DEBUG_ASYNC: 是否开启异步获取的DEBUG模式
TH2_MACHINE_NAME: 登录天河内部的机器名
TH2_MY_PATH: 路径

关于参数的详细信息, 请阅读
https://github.com/xuelangZF/ehpc/wiki/%E8%B6%85%E7%AE%97%E6%8E%A5%E5%8F%A3%E8%AF%B4%E6%98%8E%E6%96%87%E6%A1%A3
"""

TH2_BASE_URL = os.environ.get("EHPC_BASE_URL")
TH2_LOGIN_URL = "/auth"
TH2_ASYNC_URL = "/async"
TH2_ASYNC_FIRST_WAIT_TIME = 1
TH2_ASYNC_WAIT_TIME = 5
TH2_USERNAME = os.environ.get("EHPC_USERNAME")
TH2_PASSWORD = os.environ.get("EHPC_PASSWORD")
TH2_LOGIN_DATA = {"username": TH2_USERNAME, "password": TH2_PASSWORD}
TH2_DEBUG_ASYNC = True
TH2_MACHINE_NAME = os.environ.get("EHPC_MACHINE")
TH2_MY_PATH = os.environ.get("EHPC_PATH")
TH2_MAX_NODE_NUMBER = os.environ.get("EHPC_MAX_NODE_NUMBER")

"""
luosimao人机验证参数
文档地址
https://luosimao.com/docs/api/56
"""
CAPTCHA_VERIFY_URL = 'https://captcha.luosimao.com/api/site_verify'
CAPTCHA_SITE_KEY = '9179b9c905994e6dae98e52778b69c87'
CAPTCHA_API_KEY = 'e14e661452db57a55918930185270a16'


class Config:
    def __init__(self):
        pass

    SECRET_KEY = os.environ.get('SECRET_KEY') or '!@#$%^&*12345678'
    SQLALCHEMY_RECORD_QUERIES = True
    SQLALCHEMY_TRACK_MODIFICATIONS = True

    # If use QQ email, please see http://service.mail.qq.com/cgi-bin/help?id=28 firstly.
    MAIL_SERVER = 'smtp.exmail.qq.com'
    MAIL_PORT = 465
    MAIL_USE_SSL = True

    MAIL_USERNAME = os.environ.get('MAIL_USERNAME') or 'easyhpc@nscc-gz.cn'
    MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')

    # 如果配置了 EHPC_VNC_OUTSIDE_URL, 则公网可以访问， 否则只在超算内部可以访问 VNC
    VNC_SERVER_URL = os.environ.get('EHPC_VNC_OUTSIDE_URL') or '10.133.100.17:8080'
    # VNC_SERVER_URL = '114.67.37.197:10008'

    MAIL_SUBJECT_PREFIX = 'EasyHPC'
    MAIL_SENDER = '<easyhpc@nscc-gz.cn>'
    # 发送邮件开关， 为True才真正发送邮件，为False不发送邮件。
    MAIL_IS_ON = False

    BABEL_DEFAULT_LOCALE = 'zh'
    BABEL_DEFAULT_TIMEZONE = 'CST'

    PER_PAGE = 10
    UPLOAD_FOLDER = os.path.join(basedir, 'eHPC/static/upload')

    HOMEWORK_UPLOAD_FOLDER = os.path.join(basedir, 'eHPC/static/homework/upload')
    HOMEWORK_APPENDIX_FOLDER = os.path.join(basedir, 'eHPC/static/homework/appendix')       #用于暂存上传的作业附件
    COURSE_COVER_FOLDER = os.path.join(basedir, 'eHPC/static/upload/course')
    CASE_COVER_FOLDER = os.path.join(basedir, 'eHPC/static/upload/case')
    LAB_COVER_FOLDER = os.path.join(basedir, 'eHPC/static/upload/lab')
    VNC_LAB_COVER_FOLDER = os.path.join(basedir, 'eHPC/static/upload/vnc_lab')
    RESOURCE_FOLDER = os.path.join(basedir, 'eHPC/static/resource')
    CASE_FOLDER = os.path.join(basedir, 'eHPC/static/case')
    DOWNLOAD_FOLDER = os.path.join(basedir, 'eHPC/static/download')
    QRCODE_FOLDER = os.path.join(basedir, 'eHPC/static/images/QRcode')

    # 这个路径用来保存 Markdown 编辑框拖拽上传的文件
    MD_UPLOAD_IMG = 'static/upload/md_images/'
    IMAGES_FOLDER = os.path.join(basedir, 'eHPC/', MD_UPLOAD_IMG)
    # 用户头像保存的地址
    AVATAR_PATH = "static/upload/avatar/"
    AVATAR_FOLDER = os.path.join(basedir, 'eHPC/', AVATAR_PATH)

    MAX_CONTENT_LENGTH = 512 * 1024 * 1024
    ALLOWED_RESOURCE_TYPE = {'pdf', 'video', 'audio', 'excel'}

    VNC_INSIDE_SERVER_IP = os.environ.get('EHPC_VNC_PRIVATE_URL')
    VNC_OUTSIDE_SERVER_IP = os.environ.get('EHPC_VNC_PUBLIC_URL')

    CAPTCHA_SITE_KEY = CAPTCHA_SITE_KEY

    @staticmethod
    def init_app(app):
        pass


class DevelopmentConfig(Config):
    def __init__(self):
        pass

    DEBUG = True
    SQLALCHEMY_DATABASE_URI = (os.environ.get('DEV_DATABASE_URL') or
                               'mysql://root:123456@localhost/ehpc')


class ProductionConfig(Config):
    def __init__(self):
        pass

    SQLALCHEMY_DATABASE_URI = (os.environ.get('PRO_DATABASE_URL') or
                               'mysql://root:123456@localhost/ehpc')


config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}
