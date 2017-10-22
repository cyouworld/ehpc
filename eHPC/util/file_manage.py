#! /usr/bin/env python
# -*- coding: utf-8 -*-
from flask_babel import gettext
from flask import current_app
from PIL import Image
import time
import os
import re
import shutil


def upload_img(file_src, des_height, des_width, des_path):
    """ 保存 form 表单获取的上传图片到目标地址 des_path

    图片大小为 des_height * des_width,
    成功返回 True 和 图片携带的特征戳
    失败返回 False, 同时 message 里面携带失败信息.
    """
    if file_src.filename == '':
        message = gettext('No selected file')
        return False, message

    file_type = get_file_type(file_src.mimetype)

    if file_src and '.' in file_src.filename and file_type == "img":
        im = Image.open(file_src)
        # 比例会有问题
        im = im.resize((des_width, des_height), Image.ANTIALIAS)
        im.save(des_path, 'PNG')

        unique_uri = os.stat(des_path).st_mtime
        return True, unique_uri
    else:
        message = gettext("Invalid file")
        return False, message


def receive_img(des_path, img, max_height):
    """ Markdown 编辑框上传图片后台处理核心函数。

    后台处理图片文件 img, 使其宽度不超过 max_height, 超过的图片则按照比例进行缩放。
    然后保存到 path 路径指定的位置。
    返回值为一个元组:
        0. 也是一个元组: (是否上传成功的状态, 如果成功对应文件唯一的字符串或者失败对应反馈信息)
        1. 图片路径(返回给前端用)
    """
    cur_time = time.strftime("%Y%m%d%H%M%S", time.localtime()) + ".png"
    des_path = os.path.join(des_path, cur_time)
    try:
        temp = Image.open(img)
    except IOError:
        return False, None
    width, height = temp.size
    h = max_height if height > max_height else height
    w = int(1.0 * h / height * width)
    status = upload_img(img, h, w, des_path)

    # 将图片路径转换为绝对路径, 这样站点图片 url 为 domain.com/static/....
    img_link = "/%s" % os.path.join(current_app.config['MD_UPLOAD_IMG'], cur_time)
    return status[0], img_link


def upload_file(file_src, des_path, allowed_type=None):
    """ 保存 form 表单获取的文件到目标地址 des_path

    allowed_type 是 sequence 类型, 指定支持的文件类型。
    成功返回 True, 同时 unique_uri 里面携带文件信息(用于更新资源链接, 防止缓存)
    失败返回 False, 同时 message 里面携带失败信息.
    """
    if file_src.filename == '':
        message = gettext('No selected file')
        return False, message

    extension = file_src.filename[file_src.filename.rfind('.')+1:]
    file_type = extension_to_file_type(extension)
    folder = des_path[:des_path.rfind('/')]

    # 如果没有指定可以上传的文件类型, 那么使用全局的默认限制
    if not allowed_type:
        allowed_type = current_app.config['ALLOWED_RESOURCE_TYPE']

    if file_src and '.' in file_src.filename and file_type in allowed_type:
        if not os.path.exists(folder):
            os.makedirs(folder)
        file_src.save(des_path)
        unique_uri = os.stat(des_path).st_mtime
        if os.path.exists(des_path):
            app = current_app._get_current_object()
            app.homework_logger.info('homework file %s uploaded in upload_file()' % des_path)
            return True, unique_uri
        else:
            message = gettext("Save File Failed!")
            return False, message
    else:
        message = gettext("Invalid file")
        return False, message


def extension_to_file_type(extension):
    """
    将扩展名映射到后台可以识别的文件类型标识
    :param extension: 文件的扩展名
    :return: 文件类型标识
    """

    file_type_dict = {
        'jpg': 'img',
        'jpeg': 'img',
        'png': 'img',
        'bmp': 'img',
        'mp3': 'audio',
        'mp4': 'video',
        'mkv': 'video',
        'pdf': 'pdf',
        'doc': 'pdf',
        'xls': 'excel',
        'xlsx': 'excel',
        'c': 'code',
        'cpp': 'code',
        'py': 'code',
        'f': 'code',
        'zip': 'wrap',
        'rar': 'wrap',
        'gz': 'wrap',
        'tar': 'wrap'
    }

    return file_type_dict.get(extension, "Unknown")


def get_file_type(form_file_type):
    """ 获取 form 表单上传文件的类型, 这里只是做一个简单的映射。

    @from_file_type: Flask 获取到的 mimetype 类型

    Flask 通过 werkzeug 来获取文件类型, 代码如下:
    if filename and content_type is None:
        content_type = mimetypes.guess_type(filename)[0] or \
            'application/octet-stream'

    mimetypes 是 python 的文件类型检测模块, guess_type 用来猜测文件类型,
    所有的 mime_type 在下面的链接中给出:
        https://www.iana.org/assignments/media-types/media-types.xhtml
    """

    file_type_dict = {
        # 'application/msword': 'doc',
        'application/pdf': 'pdf',
        'application/msword': 'pdf',
        'video/mp4': 'video',
        'audio/mp3': 'audio',
        # 'application/vnd.ms-powerpoint': 'ppt',
        # 'application/vnd.openxmlformats-officedocument.presentationml.presentation': 'ppt',
        'video/x-matroska': 'video',
        'audio/mpeg': 'audio',
        'image/png': 'img',
        'image/jpeg': 'img',
        'image/bmp': 'img',
        'text/plain': 'code',
        'text/css': 'code',
        'text/html': 'code',
        'text/javascript': 'code',
        'application/javascript': 'code',
        'text/x-python-script': 'code',
        'text/x-fortran': 'code',
        'text/x-python': 'code',
        'text/x-csrc': 'code',
        'text/x-c++src': 'code',
        'application/x-gzip': 'wrap',
        'application/zip': 'wrap',
        'application/x-tar': 'wrap',
        'application/x-rar-compressed': 'wrap',
        'application/vnd.ms-excel': 'excel'
    }

    return file_type_dict.get(form_file_type, "Unknown")


def custom_secure_filename(filename):
    """ 将不安全的文件名转换为安全的可以在文件系统实用的安全文件名

    print custom_secure_filename('a/a/a/a.com')
    print custom_secure_filename('My cool movie.mov')
    print custom_secure_filename('../../中文测试.pdf')

    https://github.com/pallets/werkzeug/blob/0bc61df6e1ae9f2ffdf5d066aa3cd9d5ebcb307d/werkzeug/utils.py
    """
    filename = filename.encode('utf-8')

    for sep in os.path.sep, os.path.altsep:
        if sep:
            filename = filename.replace(sep, ' ')

    # unicode 中文编码范围为 /u4e00-/u9fa5
    _filename_zh_ascii_strip_re = re.compile(u"[^A-Za-z0-9_.-\u4e00-\u9fa5]")
    _windows_device_files = ('CON', 'AUX', 'COM1', 'COM2', 'COM3', 'COM4', 'LPT1',
                             'LPT2', 'LPT3', 'PRN', 'NUL')

    filename = str(_filename_zh_ascii_strip_re.sub('', '_'.join(filename.split()))).strip('._')

    # on nt a couple of special files are present in each folder.  We
    # have to ensure that the target file is not such a filename.  In
    # this case we prepend an underline
    if os.name == 'nt' and filename and filename.split('.')[0].upper() in _windows_device_files:
        filename = '_' + filename

    return filename


def remove_dirs(*dir_paths):
    """ 删除参数里面列出的所有的目录

    如果目录不存在, 不给出任何提示, 直接忽略。
    删除目录 path_1, path_2, path_3, 可以用下面操作:

        remove_dirs(path_1, path_2, path_3)
    """
    for one_dir in dir_paths:
        shutil.rmtree(one_dir, True)
