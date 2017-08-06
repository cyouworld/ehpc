#! /usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: xuezaigds@gmail.com
# @Last Modified time: 2016-09-19 23:06:09
from datetime import datetime
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from itsdangerous import TimedJSONWebSignatureSerializer as Serializer
from flask import current_app
from . import db, login_manager

""" 用户管理模块 """


class User(UserMixin, db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(128), unique=True, index=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    email = db.Column(db.String(128), unique=True, index=True, nullable=False)

    name = db.Column(db.String(128), nullable=False)
    gender = db.Column(db.Boolean, default=True)
    phone = db.Column(db.String(128), nullable=False)
    university = db.Column(db.String(128), nullable=False)
    student_id = db.Column(db.String(64), default=0, nullable=False)
    student_type = db.Column(db.Integer, default=-1, nullable=False)

    is_password_reset_link_valid = db.Column(db.Boolean, default=True)
    last_login = db.Column(db.DateTime(), default=datetime.now)
    date_joined = db.Column(db.DateTime(), default=datetime.now)

    # 权限: 0-管理员, 1-学生, 2-老师, 3-高性能计算管理员
    permissions = db.Column(db.Integer, default=1, nullable=False)
    website = db.Column(db.String(128), nullable=True)
    avatar_url = db.Column(db.String(128), default="none.jpg")
    # 个人座右铭, 用于在个人主页显示
    personal_profile = db.Column(db.Text(), nullable=True)

    # 用户创建话题, 回复等, 一对多的关系
    topics = db.relationship('Topic', backref='user', lazy='dynamic')
    topicNum = db.Column(db.Integer, default=0, nullable=False)

    posts = db.relationship('Post', backref='user', lazy='dynamic')
    postNum = db.Column(db.Integer, default=0, nullable=False)

    comments = db.relationship('Comment', backref='user', lazy='dynamic')
    commentNum = db.Column(db.Integer, default=0, nullable=False)
    open_id = db.Column(db.String(64), default=None)

    experience = db.Column(db.Integer, default=0)

    is_verify_email = db.Column(db.Boolean, default=False)
    verify_email_time = db.Column(db.DateTime())

    homeworks = db.relationship('HomeworkUpload', backref='user', lazy='dynamic')
    homework_appendix = db.relationship('HomeworkAppendix', backref='user', lazy='dynamic')

    teacher_courses = db.relationship('Course', backref='teacher', lazy='dynamic')
    teacher_questions = db.relationship('Question', backref='teacher', lazy='dynamic')
    teacher_knowledge = db.relationship('Knowledge', backref='teacher', lazy='dynamic')
    teacher_program = db.relationship('Program', backref='teacher', lazy='dynamic')
    teacher_vnc_knowledge = db.relationship('VNCKnowledge', backref='teacher', lazy='dynamic', cascade="delete, delete-orphan")
    teacher_classify = db.relationship('Classify', backref='teacher', lazy='dynamic')

    vnc_progresses = db.relationship('VNCProgress', backref='user', lazy='dynamic', cascade="delete, delete-orphan")

    machine_apply = db.relationship("MachineApply", backref='user', lazy='dynamic', cascade="delete, delete-orphan")
    machine_account = db.relationship("MachineAccount", uselist=False, backref='user')

    docker_image = db.relationship('DockerImage', uselist=False, backref='user', cascade="delete, delete-orphan")

    notifications_sent = db.relationship('Notification', backref='sender', lazy='dynamic', cascade='delete, delete-orphan')

    statistics = db.relationship('Statistic', backref='user', lazy='dynamic', cascade="delete, delete-orphan")
    submit_programs = db.relationship('SubmitProgram', backref='user', lazy='dynamic')

    @property
    def password(self):
        raise AttributeError('password is not a readable attribute')

    @password.setter
    def password(self, password):
        self.password_hash = generate_password_hash(password)

    def verify_password(self, password):
        return check_password_hash(self.password_hash, password)

    def generate_reset_token(self, expiration=600):
        s = Serializer(current_app.config['SECRET_KEY'], expiration)
        return s.dumps({'id': self.id})

    @staticmethod
    def verify_token(token):
        s = Serializer(current_app.config['SECRET_KEY'])
        try:
            data = s.loads(token)
        except:
            return None
        uid = data.get('id')
        if uid:
            return User.query.get(uid)
        return None

    def generate_email_token(self):
        expiration = 3600*24*7
        s = Serializer(current_app.config['SECRET_KEY'], expires_in=expiration)
        return s.dumps({'id': self.id})

    @staticmethod
    def verify_email_token(token):
        s = Serializer(current_app.config['SECRET_KEY'])
        try:
            data = s.loads(token)
        except:
            return None
        uid = data.get('id')
        if uid:
            return User.query.get(uid)
        return None


@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))


""" 在线课堂模块
@Course: 课程实体
@Lesson: 课时实体
@Material: 课时资源实体(PDF,PPT,MP4,MP3等资源)
@course_users: 课程和用户的多对多关系
"""
course_users = db.Table('course_users',
                        db.Column('user_id', db.Integer, db.ForeignKey('users.id')),
                        db.Column('course_id', db.Integer, db.ForeignKey('courses.id')))

course_assistants = db.Table('course_assistants',
                             db.Column('user_id', db.Integer, db.ForeignKey('users.id')),
                             db.Column('course_id', db.Integer, db.ForeignKey('courses.id')))


class Course(db.Model):
    __tablename__ = 'courses'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(128), nullable=False)           # 课程标题
    subtitle = db.Column(db.String(128), default="")            # 课程副标题
    about = db.Column(db.Text(), nullable=True)                 # 课程简介
    createdTime = db.Column(db.DateTime(), default=datetime.now)
    public = db.Column(db.Boolean, default=True)
    beginTime = db.Column(db.DateTime(), nullable=True)
    endTime = db.Column(db.DateTime(), nullable=True)

    is_hidden = db.Column(db.Boolean, default=False)            # 课程是否隐藏

    lessonNum = db.Column(db.Integer, nullable=False)           # 课时数
    studentNum = db.Column(db.Integer, default=0)               # 学生数目

    # smallPicture, middlePicture, largePicture
    smallPicture = db.Column(db.String(128))                    # 课程小图
    middlePicture = db.Column(db.String(128))                   # 课程中图
    largePicture = db.Column(db.String(128))                    # 课程大图

    rank = db.Column(db.Float, default=0)                       # 课程评分

    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    group_id = db.Column(db.Integer, db.ForeignKey('groups.id'))
    nature_order = db.Column(db.Integer, nullable=False)

    # 课程包含的课时，评价，资料等， 一对多的关系
    notices = db.relationship('Notice', backref='course', lazy='dynamic')
    lessons = db.relationship('Lesson', backref='course', lazy='dynamic')
    papers = db.relationship('Paper', backref='course', lazy='dynamic')
    homeworks = db.relationship('Homework', backref='course', lazy='dynamic')
    comments = db.relationship('Comment', backref='course', lazy='dynamic')
    # 加入该课程的用户, 多对多的关系
    users = db.relationship('User', secondary=course_users, lazy='dynamic',
                            backref=db.backref('courses', lazy='dynamic'))
    # 课程助理，多对多的关系
    assistants = db.relationship('User', secondary=course_assistants,
                                 backref=db.backref('assistant_courses', lazy='dynamic'))
    # 二维码，一对一的关系
    qrcode = db.relationship('QRcode', uselist=False, backref='course')


class Notice(db.Model):
    """ 一个课程包括多个公告，每个公告只能属于一个课程
    """
    __tablename__ = 'notices'
    id = db.Column(db.Integer, primary_key=True)                    # 公告 ID
    title = db.Column(db.String(32), nullable=False)                # 公告标题
    content = db.Column(db.Text(), default="")                      # 公告正文
    createdTime = db.Column(db.DateTime(), default=datetime.now)    # 创建时间

    courseId = db.Column(db.Integer, db.ForeignKey('courses.id'))   # 所属课程ID


class Lesson(db.Model):
    """ 一个课程包括多个课时, 每个课时只能属于一个课程。 课程和课时是一对多的关系。
    """
    __tablename__ = 'lessons'
    id = db.Column(db.Integer, primary_key=True)                    # 课时 ID
    number = db.Column(db.Integer, nullable=False)                  # 课时所在课程的编号
    title = db.Column(db.String(128), nullable=False)               # 课时标题
    content = db.Column(db.Text(), default="")                      # 课时正文
    courseId = db.Column(db.Integer, db.ForeignKey('courses.id'))   # 所属课程ID

    materials = db.relationship('Material', backref='lesson', lazy='dynamic')


class Material(db.Model):
    """ 一个课时包括多种材料, 每个材料只能属于一个课时。 课时和材料是一对多的关系。
    """
    __tablename__ = 'materials'
    id = db.Column(db.Integer, primary_key=True)          # 资料 ID
    name = db.Column(db.String(1024), nullable=False)     # 资料名称
    uri = db.Column(db.String(2048), default="")          # 资料路径
    m_type = db.Column(db.String(128), nullable=False)    # 资料类型

    lessonId = db.Column(db.Integer, db.ForeignKey('lessons.id'))  # 所属课时ID

    # 材料相关联的实验任务
    challenges = db.relationship('Challenge', backref='material', lazy='dynamic')


class Comment(db.Model):
    """ 一个课程包括多个评论, 每个评论只能属于一个课程。 课程和评论是一对多的关系。
    """
    __tablename__ = 'comments'
    id = db.Column(db.Integer, primary_key=True)  # 评论 ID
    rank = db.Column(db.Integer)                  # 评价等级
    content = db.Column(db.String(2048))          # 评价内容
    createdTime = db.Column(db.DateTime(), default=datetime.now)

    courseId = db.Column(db.Integer, db.ForeignKey('courses.id'))   # 所属课程ID
    userId = db.Column(db.Integer, db.ForeignKey('users.id'))       # 所属用户ID


""" 互动社区功能 """
group_members = db.Table('group_members',
                         db.Column('user_id', db.Integer, db.ForeignKey('users.id'), primary_key=True),
                         db.Column('group_id', db.Integer, db.ForeignKey('groups.id'), primary_key=True))


class Group(db.Model):
    def __init__(self, title, about, logo):
        self.title = title
        self.about = about
        self.logo = logo
        self.createdTime = datetime.now()

    __tablename__ = 'groups'
    id = db.Column(db.Integer, primary_key=True)        # 讨论组 ID
    title = db.Column(db.String(128), nullable=False)   # 讨论组名字
    about = db.Column(db.Text(), nullable=False)        # 讨论组介绍
    logo = db.Column(db.String(128))                    # 讨论组 Logo 的 URL

    memberNum = db.Column(db.Integer, default=0)        # 讨论组成员数目
    topicNum = db.Column(db.Integer, default=0)         # 讨论组话题数目
    createdTime = db.Column(db.DateTime(), default=datetime.now)

    # 小组内的话题，一对多的关系
    topics = db.relationship('Topic', backref='group', lazy='dynamic')
    # 小组内的成员, 多对多的关系
    members = db.relationship('User', secondary=group_members,
                              backref=db.backref('groups', lazy='dynamic'))

    course = db.relationship('Course', uselist=False, backref='group')


class Topic(db.Model):
    def __init__(self, user_id, title, content, group_id):
        self.userID = user_id
        self.title = title
        self.content = content
        self.createdTime = datetime.now()
        self.updatedTime = datetime.now()
        self.groupID = group_id

    __tablename__ = 'topics'
    id = db.Column(db.Integer, primary_key=True)                # 话题 ID
    title = db.Column(db.String(128), nullable=False)            # 话题标题
    content = db.Column(db.Text(), nullable=False)              # 话题内容
    visitNum = db.Column(db.Integer, default=0)                 # 话题浏览次数
    postNum = db.Column(db.Integer, default=0)                  # 评论次数
    groupID = db.Column(db.Integer, db.ForeignKey('groups.id')) # 所属群组的ID
    userID = db.Column(db.Integer, db.ForeignKey('users.id'))   # 创建用户的ID

    createdTime = db.Column(db.DateTime(), default=datetime.now)
    updatedTime = db.Column(db.DateTime(), default=datetime.now)

    # 话题的评论，一对多的关系
    posts = db.relationship('Post', backref='topic', lazy='dynamic')


class Post(db.Model):
    def __init__(self, user_id, content):
        self.content = content
        self.userID = user_id
        self.createdTime = datetime.now()

    __tablename = "posts"
    id = db.Column(db.Integer, primary_key=True)                # 评论的ID
    content = db.Column(db.String(1024), nullable=False)        # 评论内容

    topicID = db.Column(db.Integer, db.ForeignKey('topics.id')) # 所属话题的ID
    userID = db.Column(db.Integer, db.ForeignKey('users.id'))   # 回复用户的ID
    createdTime = db.Column(db.DateTime(), default=datetime.now)


""" 试题中心模块
@Program:           对应在线编程题
@SubmitProgram:     对应编程题目提交记录
@Choice:            对应选择题
@Classify:          选择题目所属的分类
@PaperQuestion:     试卷和题目是多对多的关系, 并且试卷中的题目有自己的分值, 因此需要建一个关联表
@Paper:             试卷实体
@Question:          选择题, 填空题, 判断题等题型
"""


homework_program = db.Table('homework_program',
                               db.Column('homework_id', db.Integer, db.ForeignKey('homework.id'), primary_key=True),
                               db.Column('program_id', db.Integer, db.ForeignKey('programs.id'), primary_key=True))


class Program(db.Model):
    __tablename__ = "programs"
    id = db.Column(db.Integer, primary_key=True)        # 题目 ID
    title = db.Column(db.String(128), nullable=False)   # 题目标题
    detail = db.Column(db.Text(), nullable=False)       # 题目详情
    difficulty = db.Column(db.Integer, default=0)       # 题目难度
    acceptedNum = db.Column(db.Integer, default=0)      # 通过次数
    submitNum = db.Column(db.Integer, default=0)        # 提交次数

    default_code = db.Column(db.Text(), default="")   # 预先设定的代码

    can_evaluate = db.Column(db.Boolean, default=False)  # 是否支持评测
    pi_code = db.Column(db.Text(), default="")  # 评测主代码
    null_code = db.Column(db.Text(), default="")  # 参考空代码
    serial_code = db.Column(db.Text(), default="")  # 参考串行代码
    ref_code = db.Column(db.Text(), default="")  # 参考并行代码

    createdTime = db.Column(db.DateTime(), default=datetime.now)

    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    homework = db.relationship('Homework', secondary=homework_program, backref=db.backref('program', lazy='dynamic'))
    submit_programs = db.relationship('SubmitProgram', backref='program', lazy='dynamic')


class SubmitProgram(db.Model):
    # 一个题目可以有很多人提交,一个人可以提交多个题目。所以题目和用户是多对多的关系
    def __init__(self, user_id, program_id, source_code, language):
        self.uid = user_id
        self.pid = program_id
        self.code = source_code
        self.language = language
        self.submit_time = datetime.now()

    __tablename__ = "submit_programs"
    id = db.Column(db.Integer, primary_key=True)                    # 提交记录id
    pid = db.Column(db.Integer, db.ForeignKey('programs.id'))       # 本次提交的题目ID
    uid = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)   # 本次提交的用户ID
    code = db.Column(db.Text(), nullable=False)                     # 本次提交的提交代码
    language = db.Column(db.String(128), nullable=False)            # 本次提交的代码语言
    submit_time = db.Column(db.DateTime(), default=datetime.now)    # 本次提交的提交时间
    status = db.Column(db.String(128))                              # 本次提交的运行结果


question_classifies = db.Table('question_classifies',
                               db.Column('question_id', db.Integer, db.ForeignKey('questions.id'), primary_key=True),
                               db.Column('classify_id', db.Integer, db.ForeignKey('classifies.id'), primary_key=True))


class PaperQuestion(db.Model):
    __tablename__ = "paper_question"
    question_id = db.Column(db.Integer, db.ForeignKey('questions.id'), primary_key=True)
    paper_id = db.Column(db.Integer, db.ForeignKey('papers.id'), primary_key=True)
    point = db.Column(db.Integer, nullable=False)

    papers = db.relationship('Paper', backref=db.backref('questions', lazy='dynamic', cascade="delete, delete-orphan"))
    questions = db.relationship('Question', backref=db.backref('papers', lazy='dynamic', cascade="delete, delete-orphan"))


class Question(db.Model):
    __tablename__ = "questions"
    id = db.Column(db.Integer, primary_key=True)               # 题目 ID
    # 0:单选题 1:多选题 2:不定项选择题 3: 填空题 4: 判断题 5: 问答题
    type = db.Column(db.Integer, nullable=False)               # 题目类别
    content = db.Column(db.String(2048), nullable=False)       # 题干(选择题包括选项)
    solution = db.Column(db.String(512), nullable=False)       # 题目答案
    analysis = db.Column(db.String(1024), default="")          # 答案解析

    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))

    classifies = db.relationship('Classify', secondary=question_classifies,
                                 backref=db.backref('questions', lazy='dynamic'))


class Paper(db.Model):
    def __init__(self, title, about):
        self.title = title
        self.about = about

    __tablename__ = "papers"
    id = db.Column(db.Integer, primary_key=True)        # 试卷 ID
    title = db.Column(db.String(128), nullable=False)   # 试卷标题
    about = db.Column(db.String(128), nullable=False)   # 试卷简介
    courseId = db.Column(db.Integer, db.ForeignKey('courses.id'))


class Classify(db.Model):
    __tablename__ = "classifies"
    id = db.Column(db.Integer, primary_key=True)        # 分类 ID
    name = db.Column(db.String(128), nullable=False)    # 分类名字

    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))


""" 咨询信息
@Article: 用来发布站点公告或者一些资讯、新闻信息。
"""


class Article(db.Model):
    __tablename__ = "articles"
    id = db.Column(db.Integer, primary_key=True)        # 资讯 ID
    title = db.Column(db.String(128), nullable=False)   # 资讯标题
    content = db.Column(db.Text(), nullable=False)      # 资讯正文
    visitNum = db.Column(db.Integer, default=0)         # 浏览次数

    updatedTime = db.Column(db.DateTime(), default=datetime.now)


""" 虚拟实验室模块
@Knowledge: 需要练习的技能
@Challenge: 一个技能中的一个小任务模块
@Progress: 记录用户学习某个知识的进度, 多对多的一个关系
"""


class Knowledge(db.Model):
    __tablename__ = "knowledges"
    id = db.Column(db.Integer, primary_key=True)        # 技能 ID
    title = db.Column(db.String(1024), nullable=False)  # 技能标题
    content = db.Column(db.Text(), default=None)        # 技能简介
    cover_url = db.Column(db.String(512), default='upload/lab/default.png')
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))

    # 一个技能对应了很多任务, 一对多的关系。
    challenges = db.relationship('Challenge', backref='knowledge', lazy='dynamic')


class Challenge(db.Model):
    __tablename__ = "challenges"
    id = db.Column(db.Integer, primary_key=True)        # 任务 ID
    title = db.Column(db.String(1024), nullable=False)  # 技能标题
    content = db.Column(db.Text(), nullable=False)      # 知识点图文内容

    # 所属技能ID以及对应技能下任务的次序, 可以用来唯一确定一个任务
    knowledgeId = db.Column(db.Integer, db.ForeignKey('knowledges.id'))
    knowledgeNum = db.Column(db.Integer, default=1)

    # 每一个任务可能有一个教学材料, 如果为空, 则表示没有材料, 纯图文内容。
    materialId = db.Column(db.Integer, db.ForeignKey('materials.id'))
    source_code = db.Column(db.Text(), nullable=False)
    default_code = db.Column(db.Text(), default=None)

    task_number = db.Column(db.Integer, default=1)
    cpu_number_per_task = db.Column(db.Integer, default=1)
    node_number = db.Column(db.Integer, default=1)
    language = db.Column(db.String(64), nullable=False)


class Progress(db.Model):
    __tablename__ = "progress"

    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), primary_key=True)                # 用户 ID
    knowledge_id = db.Column(db.Integer, db.ForeignKey('knowledges.id'), primary_key=True)      # 技能 ID
    cur_progress = db.Column(db.Integer, default=0)     # 用户 user_id 在知识点 knowledge_id 上已经完成的最后一个任务
    update_time = db.Column(db.DateTime, nullable=False)

    knowledge = db.relationship('Knowledge', backref=db.backref('users',
                                                                lazy='dynamic', cascade="delete, delete-orphan"))
    user = db.relationship('User', backref=db.backref('progresses',
                                                      lazy='dynamic', cascade="delete, delete-orphan"))


class VNCKnowledge(db.Model):
    __tablename__ = 'vnc_knowledge'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(1024), nullable=False)
    about = db.Column(db.Text(), nullable=False)
    cover_url = db.Column(db.String(512), default='upload/vnc_lab/default.png')
    teacher_id = db.Column(db.Integer, db.ForeignKey('users.id'))

    # 一个实验对应多个小任务，一个小任务只属于一个实验
    vnc_tasks = db.relationship('VNCTask', backref='vnc_knowledge', lazy='dynamic', cascade="delete, delete-orphan")
    vnc_progresses = db.relationship('VNCProgress', backref='vnc_knowledge', lazy='dynamic', cascade="delete, delete-orphan")


class VNCTask(db.Model):
    __tablename__ = 'vnc_tasks'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(1024), nullable=False)
    content = db.Column(db.Text(), nullable=False)

    vnc_knowledge_id = db.Column(db.Integer, db.ForeignKey('vnc_knowledge.id'))
    vnc_task_num = db.Column(db.Integer, default=1)


class VNCProgress(db.Model):
    __tablename__ = 'vnc_progresses'
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), primary_key=True)
    vnc_knowledge_id = db.Column(db.Integer, db.ForeignKey('vnc_knowledge.id'), primary_key=True)
    have_done = db.Column(db.Integer, default=0)
    update_time = db.Column(db.DateTime, nullable=False)


""" 案例展示 """


class Case(db.Model):
    __tablename__ = "cases"

    id = db.Column(db.Integer, primary_key=True)        # 案例 ID
    name = db.Column(db.String(256), nullable=False)    # 案例名字
    description = db.Column(db.Text(), nullable=False)  # 案例描述
    icon = db.Column(db.String(64), nullable=False)     # 案例 Logo
    tag = db.Column(db.String(256))                     # 案例标签，两个标签之间用分号隔开

    versions = db.relationship('CaseVersion', backref='case', lazy='dynamic', cascade='delete, delete-orphan')


class CaseVersion(db.Model):
    __tablename__ = "case_versions"

    id = db.Column(db.Integer, primary_key=True)
    case_id = db.Column(db.Integer, db.ForeignKey('cases.id'), nullable=False)
    version_id = db.Column(db.Integer, nullable=False)
    name = db.Column(db.String(256), nullable=False)
    description = db.Column(db.String(256), nullable=False)
    dir_path = db.Column(db.String(128), nullable=False)

    materials = db.relationship('CaseCodeMaterial', backref='version', lazy='dynamic', cascade='delete, delete-orphan')


class CaseCodeMaterial(db.Model):
    """ 一个版本包括多份代码, 每份代码只能属于一个版本。版本和代码是一对多的关系。
    """
    __tablename__ = 'case_code_materials'
    id = db.Column(db.Integer, primary_key=True)          # 代码 ID
    version_id = db.Column(db.Integer, db.ForeignKey('case_versions.id'), nullable=False)
    name = db.Column(db.String(1024), nullable=False)     # 代码文件名称
    uri = db.Column(db.String(256), default="")           # 代码路径


""" 作业管理
@Homework: 作业实体集
@HomeworkUpload: 提交作业联系集
"""


class Homework(db.Model):
    __tablename__ = "homework"

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(256), nullable=True)
    h_type = db.Column(db.Integer, default=0, nullable=False)    #作业类型：0--理论作业；1--编程作业
    description = db.Column(db.Text(), nullable=True)
    publish_time = db.Column(db.DateTime, default=datetime.now, nullable=False)
    deadline = db.Column(db.DateTime, nullable=True)
    course_id = db.Column(db.Integer, db.ForeignKey('courses.id'), nullable=False)

    uploads = db.relationship('HomeworkUpload', backref='homework', lazy='dynamic', cascade='delete, delete-orphan')
    appendix = db.relationship('HomeworkAppendix', backref='homework', lazy='dynamic', cascade='delete, delete-orphan')
    homework_scores = db.relationship("HomeworkScore", backref='homework', lazy='dynamic', cascade='delete, delete-orphan')


class HomeworkUpload(db.Model):
    __tablename__ = "homework_upload"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(256), nullable=False)
    homework_id = db.Column(db.Integer, db.ForeignKey('homework.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    uri = db.Column(db.String(256), nullable=False)
    submit_time = db.Column(db.DateTime, default=datetime.now, nullable=False)


class HomeworkAppendix(db.Model):
    __tablename__ = "homework_appendix"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(256), nullable=False)
    homework_id = db.Column(db.Integer, db.ForeignKey('homework.id'))
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    uri = db.Column(db.String(256), nullable=False)
    upload_time = db.Column(db.DateTime, default=datetime.now, nullable=False)


class Apply(db.Model):
    """ 老师对学生加入课程的审批
    """
    __tablename__ = "apply"
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    course_id = db.Column(db.Integer, db.ForeignKey('courses.id'))
    status = db.Column(db.Integer, nullable=False)  # 0 待定 1 同意

    user = db.relationship('User', backref=db.backref('applies', lazy='dynamic', cascade="delete, delete-orphan"))
    course = db.relationship('Course', backref=db.backref('applies', lazy='dynamic', cascade="delete, delete-orphan"))


class QRcode(db.Model):
    __tablename__ = "qrcode"
    id = db.Column(db.Integer, primary_key=True)
    end_time = db.Column(db.DateTime, nullable=False)
    course_id = db.Column(db.Integer, db.ForeignKey('courses.id'))


class CodeCache(db.Model):
    def __init__(self, uid, pid, code):
        self.user_id = uid
        self.program_id = pid
        self.code = code

    __tablename__ = "code_cache"
    id = db.Column(db.Integer, nullable=False, primary_key=True)
    user_id = db.Column(db.Integer, nullable=False)
    program_id = db.Column(db.Integer, nullable=False)
    code = db.Column(db.Text(), default=None)


class HomeworkScore(db.Model):
    __tablename__ = "homework_score"
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, primary_key=True)
    homework_id = db.Column(db.Integer, db.ForeignKey('homework.id'), nullable=False, primary_key=True)
    score = db.Column(db.Integer, nullable=False)
    comment = db.Column(db.String(1024), nullable=True)
    status = db.Column(db.Integer, nullable=False, default=2)      #此学生作业提交状态：0-已交；1-迟交；2-未交

    user = db.relationship("User", backref='homeworkscore')


class MachineApply(db.Model):
    __tablename__ = "machine_apply"
    id = db.Column(db.Integer, primary_key=True)
    applicant_name = db.Column(db.String(64), nullable=True)  # 申请人姓名
    applicant_institution = db.Column(db.String(64), nullable=True)  # 申请人单位
    applicant_tel = db.Column(db.String(64), nullable=True)  # 申请人电话号码
    applicant_email = db.Column(db.String(64), nullable=True)  # 申请人电子邮件
    applicant_address = db.Column(db.String(128), nullable=True)  # 项申请人地址
    manager_name = db.Column(db.String(64), nullable=True)  # 项目负责人姓名
    manager_institution = db.Column(db.String(64), nullable=True)  # 项目负责人单位
    manager_tel = db.Column(db.String(64), nullable=True)  # 项目负责人电话号码
    manager_email = db.Column(db.String(64), nullable=True)  # 项目负责人电子邮件
    manager_address = db.Column(db.String(128), nullable=True)  # 项目负责人地址
    project_name = db.Column(db.String(128), nullable=True)  # 项目名称
    sc_center = db.Column(db.Integer, nullable=True, default=0)  # 超算单位：0-广州超算，1-长沙超算，2-中科院超算，3-上海超算
    cpu_hour = db.Column(db.Integer, nullable=True, default=0)  # CPU核时，CPU_hour字段不能置空，若用户未填写则默认为0
    usage = db.Column(db.String(512), nullable=True)  # 机时用途说明
    applying_time = db.Column(db.DateTime, default=datetime.now, nullable=False)  # 提交申请的时间
    submit_status = db.Column(db.Integer, default=0)  # 当前申请的提交状态：0-未提交，1-已提交，等待审批，2-审批通过，3-申请被拒绝

    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))


class MachineAccount(db.Model):
    __tablename__ = "machine_account"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64))
    password = db.Column(db.String(64))
    key = db.Column(db.String(256))
    ip = db.Column(db.String(64))
    port = db.Column(db.Integer)
    token = db.Column(db.String(64), default=None)

    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))


class DockerHolder(db.Model):
    STOPPED = 0
    RUNNING = 1

    def __init__(self):
        self.status = 0
        self.running_container_count = 0
        self.images_count = 0

    __tablename__ = "docker_holders"
    id = db.Column(db.Integer, nullable=False, primary_key=True)
    name = db.Column(db.String(256), nullable=False)
    ip = db.Column(db.String(128), nullable=False)
    inner_ip = db.Column(db.String(128), nullable=False)
    public_port = db.Column(db.Integer, nullable=False)
    inner_port = db.Column(db.Integer, nullable=False)
    status = db.Column(db.Integer, default=0)   # 0: 停止 1: 运行
    running_container_count = db.Column(db.Integer, default=0)
    images_count = db.Column(db.Integer, default=0)

    docker_images = db.relationship('DockerImage', backref='docker_holder', lazy='dynamic', cascade="delete, delete-orphan")


class DockerImage(db.Model):
    DISCONNECTED = 0
    READY_TO_CONNECT = 1
    CONNECTED = 2

    STATUS_CREATE_USER_IMAGE_FAIL = 4001
    STATUS_CREATE_USER_IMAGE_SUCCESSFULLY = 4002
    STATUS_START_VNC_SERVER_FAIL = 4003
    STATUS_START_VNC_SERVER_SUCCESSFULLY = 4004
    STATUS_SET_RESOLUTION_FAIL = 4005
    STATUS_SET_RESOLUTION_SUCCESSFULLY = 4006
    STATUS_START_IMAGE_FAIL = 4007
    STATUS_START_IMAGE_SUCCESSFULLY = 4008
    STATUS_STOP_IMAGE_FAIL = 4009
    STATUS_STOP_IMAGE_SUCCESSFULLY = 4010
    STATUS_START_SSH_SERVER_FAIL = 4011
    STATUS_START_SSH_SERVER_SUCCESSFULLY = 4012

    MESSAGE_CREATE_CONTAINER_FAIL = "Failed to create a new container when creating a new user image"
    MESSAGE_SET_VNC_SERVER_PASSWORD_FAIL = "Failed to set vnc server when creating a new user image"
    MESSAGE_START_VNC_SERVER_FAIL = "Failed to start the vnc server when starting the vnc server"
    MESSAGE_STOP_VNC_SERVER_FAIL = "Failed to stop the vnc server when setting resolution"
    MESSAGE_START_VNC_SERVER_WITH_RESOLUTION_FAIL = \
        "Failed to start the vnc server with given resolution when setting resolution"

    def __init__(self, vnc_password, ssh_password, name, user_id):
        self.last_connect_time = None
        self.remaining_time_today = 14400
        self.tunnel_id = None
        self.vnc_password = vnc_password
        self.ssh_password = ssh_password
        self.status = 0
        self.is_running = False
        self.is_vnc_running = False
        self.is_ssh_running = False
        self.token = None
        self.name = name
        self.user_id = user_id

    __tablename__ = "docker_images"
    id = db.Column(db.Integer, nullable=False, primary_key=True)
    create_time = db.Column(db.DateTime, default=datetime.now, nullable=False)
    last_connect_time = db.Column(db.DateTime, default=None)
    remaining_time_today = db.Column(db.Integer, default=14400)  # 每天4小时
    port = db.Column(db.Integer, default=0)
    tunnel_id = db.Column(db.String(256), default=None)
    vnc_password = db.Column(db.String(128), nullable=False)
    ssh_password = db.Column(db.String(128), nullable=False)
    status = db.Column(db.Integer, default=0)  # 0: 未连接, 1: 准备连接, 2: 已连接
    is_running = db.Column(db.Boolean, default=False)
    is_vnc_running = db.Column(db.Boolean, default=False)
    is_ssh_running = db.Column(db.Boolean, default=False)
    token = db.Column(db.String(64), default=None)
    name = db.Column(db.String(64), nullable=False)

    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, unique=True)
    docker_holder_id = db.Column(db.Integer, db.ForeignKey('docker_holders.id'), default=None)


class NotificationReceiver(db.Model):
    __tablename__ = "notifications_receivers"
    id = db.Column(db.Integer, nullable=False, primary_key=True)
    notification_id = db.Column(db.Integer, db.ForeignKey('notifications.id'))
    receiver_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    is_read = db.Column(db.Boolean, default=False)
    read_time = db.Column(db.DateTime, default=None)

    receiver = db.relationship('User', uselist=False, backref=db.backref('note_info', lazy='dynamic', cascade="delete, delete-orphan"))
    notification = db.relationship('Notification', uselist=False, backref=db.backref('note_info', lazy='dynamic', cascade="delete, delete-orphan"))


class Notification(db.Model):
    def __init__(self, event_name, event_content):
        self.event_name = event_name
        self.event_content = event_content

    __tablename__ = "notifications"
    id = db.Column(db.Integer, nullable=False, primary_key=True)
    create_time = db.Column(db.DateTime, default=datetime.now, nullable=False)
    event_name = db.Column(db.String(512), nullable=False)
    event_content = db.Column(db.Text(), nullable=False)

    sender_id = db.Column(db.Integer, db.ForeignKey('users.id'), default=None)


class Statistic(db.Model):
    ACTION_USER_VISIT_MAIN_PAGE = 10001
    # ACTION_USER_VISIT_PERSONAL_HOME_PAGE = 10001

    ACTION_COURSE_VISIT_DOCUMENT_OR_VIDEO = 20001
    ACTION_COURSE_ATTEND_QUIZ = 20002
    ACTION_COURSE_SUBMIT_QUIZ_ANSWER = 20003
    # ACTION_COURSE_COMMENT = 20004

    # ACTION_QUESTION_VISIT_QUESTION_PAGE = 30001
    ACTION_QUESTION_SUBMIT_ANSWER = 30002

    # ACTION_PROGRAM_VISIT_PROGRAM_PAGE = 40001
    # ACTION_PROGRAM_SUBMIT_CODE = 40002

    # ACTION_TOPIC_CREATE_TOPIC = 50001

    # ACTION_LAB_VISIT_PROGRAMING_LAB = 60001
    ACTION_LAB_PASS_A_PROGRAMING_TASK = 60002
    # ACTION_LAB_VISIT_CONFIGURATION_LAB = 60003
    ACTION_LAB_PASS_A_CONFIGURATION_TASK = 60004

    def __init__(self, user_id, action, data):
        self.user_id = user_id
        self.action = action
        self.data = data

    __tablename__ = 'statistics'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    action = db.Column(db.Integer, nullable=False)
    data = db.Column(db.Text(), default=None)
    timestamp = db.Column(db.DateTime(), default=datetime.now)


