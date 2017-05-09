#! /usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: xuezaigds@gmail.com
# @Last Modified time: 2016-10-08 14:38:43
import os
from eHPC import create_app, db
from flask import url_for
from flask_script import Manager
from flask_migrate import Migrate, MigrateCommand
from flask_babel import Babel
from flask_wtf.csrf import CSRFProtect
from eHPC import wechat

app = create_app(os.getenv('EHPC_CONFIG') or 'default')


@app.context_processor
def override_url_for():
    """ Static url cache buster

    Issue 296: https://github.com/xuelangZF/ehpc/issues/296
    According to http://flask.pocoo.org/snippets/40/
    """
    return dict(url_for=dated_url_for)


def dated_url_for(endpoint, **values):
    if endpoint == 'static':
        filename = values.get('filename', None)
        # pdf.js 用来加载 PDF, 这个特例不需要加查询戳
        if filename == 'js/pdfjs/web/viewer.html':
            pass
        # 获取课时资源的目录，后面还要再追加具体的地址。
        elif filename =='resource':
            pass
        elif filename:
            file_path = os.path.join(app.root_path,
                                     endpoint, filename)
            # 如果静态资源不存在, 则会抛出异常, 异常中不用做处理。
            try:
                values['q'] = int(os.stat(file_path).st_mtime)
            except OSError:
                pass
    return url_for(endpoint, **values)

manager = Manager(app)
migrate = Migrate(app, db)
babel = Babel(app)
csrf = CSRFProtect(app)
csrf.exempt(wechat.views.process)

manager.add_command('db', MigrateCommand)


if __name__ == '__main__':
    manager.run()
