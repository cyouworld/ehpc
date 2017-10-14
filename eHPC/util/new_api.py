#! /usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: xuezaigds@gmail.com
import json
import logging
import re
import threading
import time

from datetime import datetime
import six
from six.moves.urllib import request, parse
from six.moves.urllib.error import HTTPError, URLError

from flask import jsonify

# from config import TH2_MAX_NODE_NUMBER, TH2_BASE_URL, TH2_ASYNC_WAIT_TIME, TH2_LOGIN_DATA, TH2_MACHINE_NAME, \
#     TH2_DEBUG_ASYNC, TH2_MY_PATH, TH2_ASYNC_FIRST_WAIT_TIME, TH2_ASYNC_URL, TH2_LOGIN_URL, \
#     TH2_BASE_URL_NEW, TH2_USERNAME_NEW, TH2_PASSWORD_NEW, TH2_MACHINE_NAME_NEW, TH2_MY_PATH_NEW, TH2_LOGIN_DATA_NEW

th2_logger = logging.getLogger('th2')
th2_logger.setLevel(logging.DEBUG)
file_handler = logging.FileHandler('app_logs/TH2.log')
# file_handler = logging.FileHandler('../../app_logs/TH2.log')
file_handler.setLevel(logging.DEBUG)
file_handler.setFormatter(logging.Formatter('%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s'))
th2_logger.addHandler(file_handler)

global g__cookies
global TH2_MY_PATH, TH2_BASE_URL, TH2_USERNAME, TH2_PASSWORD, TH2_MACHINE_NAME, TH2_LOGIN_DATA

TH2_BASE_URL="http://a002.nscc-gz.cn:10218/api"
TH2_USERNAME="sysu_hpc_dwu_1"
TH2_PASSWORD="cecbc7eae5e43ee0"
TH2_MACHINE_NAME="ln7"
TH2_MY_PATH="/HOME/sysu_hpc_dwu_1/project/ehpc"

TH2_LOGIN_DATA = {"username": TH2_USERNAME, "password": TH2_PASSWORD}

#TH2_BASE_URL_NEW="http://a002.nscc-gz.cn:10307/api"
#TH2_USERNAME_NEW="testuser"
#TH2_PASSWORD_NEW="test123qaz"

TH2_BASE_URL_NEW="http://114.67.37.2:10353/v1"
TH2_USERNAME_NEW="astaxie"
TH2_PASSWORD_NEW="11111"
TH2_MACHINE_NAME_NEW="local"
TH2_MY_PATH_NEW="/HOME/testuser1/new_api"
TH2_LOGIN_DATA_NEW = {"username": TH2_USERNAME_NEW, "password": TH2_PASSWORD_NEW}

TH2_LOGIN_URL = "/auth"
TH2_ASYNC_URL = "/async"
TH2_ASYNC_FIRST_WAIT_TIME = 1
TH2_ASYNC_WAIT_TIME = 5
TH2_DEBUG_ASYNC = True
TH2_MAX_NODE_NUMBER=60

# 完成天河2号接口的功能的客户端
class ehpc_client_new:
    def __init__(self, base_url=TH2_BASE_URL_NEW, headers={}, login_cookie=None, login_data=TH2_LOGIN_DATA_NEW):
        global TH2_MY_PATH, TH2_BASE_URL, TH2_USERNAME, TH2_PASSWORD, TH2_MACHINE_NAME, TH2_LOGIN_DATA

        self.headers = headers
        self.base_url = base_url
        self.login_cookie = login_cookie
        self.login_data = login_data
        self.async_wait_time = TH2_ASYNC_WAIT_TIME
        self.username = None
        self.resp = request.urlopen("http://www.baidu.com")

        global g__cookies

        try:
            if 'cookie' in g__cookies:
                pass
                if self.login_data is None:
                    self.login_data = g__cookies['cookie']
        except NameError:
            g__cookies = {}

    # 登录，返回值为是否成功（布尔型）
    # POST /api/auth
    def login(self):
        # print self.login_data
        tmpdata = self.open(TH2_LOGIN_URL, data=self.login_data, login=False)
        self.login_cookie = self.resp.headers['Set-Cookie']
        self.username = self.login_data['username']
        global g__cookies

        try:
            g__cookies['cookie'] = self.login_cookie
        except NameError:
            g__cookies = {'cookie': self.login_cookie}

        th2_logger.debug("Login returned data: %s" % tmpdata)

        return self.ret200()

    def open(self, url, data=None, method=None, login=True, async_get=True, async_wait=True, retjson=True,
             setcookies=False, headers=None, datajson=True):
        """ 入口函数，完成接收前端数据-发送请求到特定api接口-接收并保存返回数据的功能

        将接收的字典格式数据data封装进request请求，根据url参数发送到对应的api接口的地址，并对返回的数据进行
        处理以及保存。中间会根据参数对是否登录以及异步获取进行判断。

        返回值为一个字典，即api接口返回的数据。
        """

        url = self.base_url + url

        # 请求数据中带有查询字典或者form表单时，将其封装为 application/x-www-form-urlencoded string类型。
        # 如果请求数据为 unicode类型（上传的代码），则将其编码为 utf-8, 转为 str 类型。
        if data:
            try:
                if method != 'PUT':
                    if datajson:
                        data = json.dumps(data).encode(encoding='UTF8')
                    else:
                        data = parse.urlencode(data).encode(encoding='UTF8')
                else:
                    data = data.encode('utf-8')
            except TypeError as ex:
                th2_logger.debug(data)
                th2_logger.debug(ex)
                pass

            # Data may be a string specifying additional data to send to the server
            req = request.Request(url, data)
        else:
            req = request.Request(url)

        # 如果需要登录权限，则查看请求中是否需要 cookie 。如果没有cookie，则调用login函数登录并保存cookie数据
        if login:
            if not self.login_cookie:
                self.login()

            # req.add_header("content-type", "application/json")
            req.add_header("Cookie", self.login_cookie)

        if headers:
            for (k, v) in headers.items():
                req.add_header(k, v)

        # 添加其他头部信息
        for (k, v) in self.headers:
            req.add_header(k, v)

        if datajson:
            req.add_header('Content-Type', "application/json")
        # 设置请求方法
        if method:
            req.get_method = lambda: method

        # 发送请求，请接受返回数据
        try:
            noerror = True
            resp = request.urlopen(req)
            self.resp = resp
            rdata = resp.read()

            # print(resp.status)
            # print (resp.code)
            # print rdata

        except HTTPError, e:  # HTTPError必须排在URLError的前面
            # print "The server couldn't fulfill the request.  Error code:", e.code
            noerror = False
            th2_logger.debug("The server couldn't fulfill the request.  Error code:", e.code)
            rdata = e.fp.read()
            self.status_code = e.code
        except URLError as e:
            self.status_code = 500
            self.status = "ERROR"
            self.output = str(e)
            # print "Failed to reach the server. The reason:", e.reason
            th2_logger.debug("Failed to reach the server. The reason:", e.reason)
            return
        except Exception as e:
            if six.PY3:
                rdata = e.args[0]
            else:
                raise e

        if not retjson:
            th2_logger.debug(dict(resp))
            self.data = rdata
            self.status_code = resp.code
            self.status = "OK" if resp.code == 200 else "ERROR"
            self.output = self.data
            return self.data

        if isinstance(rdata, bytes):
            rdata = rdata.decode('utf-8')
        # rdata_reg = re.search('\{.+\}', rdata)
        rdata_reg = re.search('{.}', rdata)
        rdata = rdata if rdata_reg is None else rdata_reg.group()
        # print(rdata)
        # 保存数据
        try:
            rdata = json.loads(rdata)
            self.data = rdata

            if noerror:
                if six.PY3:
                    self.status_code = resp.status
                else:
                    self.status_code = resp.code

            if self.status_code == 200:
                self.status = "OK"
            else:
                self.status = "ERROR"

        except ValueError as exc:
            # print(exc)
            th2_logger.debug("exe : %s" % exc)
            th2_logger.debug(("rdata : %s" % rdata))
            self.data = rdata
            try:
                self.status = rdata['status']
                self.status_code = rdata["status_code"]
            except Exception as exc:
                try:
                    self.status = rdata['status']
                    self.status_code = rdata["status_code"]
                except Exception as ex:
                    self.status_code = 200
                    self.status = 200
                self.status = "unknown"
            self.output = self.data
            if self.status_code == 200: self.status = "OK"

        if setcookies:
            self.login_cookie = self.resp.headers['Set-Cookie3']

        # 如果开启了异步获取并且返回码是201,表示转入异步获取请求结果的状态
        if self.status_code == 201 and async_get:
            self.async_wait_time = TH2_ASYNC_WAIT_TIME
            time.sleep(TH2_ASYNC_FIRST_WAIT_TIME)
            if TH2_DEBUG_ASYNC:
                pass
                th2_logger.debug("jump to async")
            th2_logger.debug(self.output)
            return self.open(TH2_ASYNC_URL + '/' + self.output)

        # 如果返回码是100 continue并且设置了异步获取等待，继续请求
        if self.status_code == 100 and async_wait and self.async_wait_time > 0:
            time.sleep(1)
            self.async_wait_time -= 1
            if TH2_DEBUG_ASYNC:
                pass
                th2_logger.debug("async retry")
            return self.open(TH2_ASYNC_URL + '/' + self.output)

        # 超时
        if self.async_wait_time <= 0:
            th2_logger.debug("Error: async connection time out.")
            self.async_wait_time = TH2_ASYNC_WAIT_TIME

        return self.data

    # 对返回结果的判断函数
    def ret200(self):
        return self.status == "OK" and self.status_code == 200

    def ret403(self):
        return self.status == "ERROR" and self.status_code == 403

    def ret500(self):
        return self.status == "ERROR" and self.status_code == 500

    def retError(self):
        return self.status == "ERROR"

    # 登出，返回值为是否成功（布尔型）
    # DELETE /api/auth
    def logout(self):
        self.open("/auth", login=True, method="DELETE")
        return self.ret200()

    # 暂时没有使用
    # GET /api/file/<machine>/<path>列目录
    def get_directory(self, myPath):
        tmpdata = self.open("/file/" + TH2_MACHINE_NAME + myPath + '/')
        return tmpdata

    # GET /api/file/<machine>/<path>?download=True
    def download(self, myPath, filename, isSmallApiServer=True, isjob=False):
        """ 下载给出路径中的文件内容，如果是脚本文件需要先对文件名进行处理

        首先对是否为脚本文件进行判断，然后获取文件的状态，从状态信息中取出保存结果的文件id

        最后获取结果文件

        返回的是输出结果（字符串）
        """
        if isjob:
            filename = "slurm-%s.out" % filename
        tmpdata = self.open("/file/" + TH2_MACHINE_NAME + myPath + '/' + filename + "?download=true")

        # print tmpdata
        if isSmallApiServer:
            tmpdata = tmpdata
        else:
            async_id = tmpdata["output"]
            # print async_id
            tmpdata = self.open("/file/" + TH2_MACHINE_NAME + "/%s?download=true" % async_id)
        # tmpdata = tmpdata if isinstance(tmpdata, str) else tmpdata.decode('utf-8')

        th2_logger.debug("Download returned data: %s" % tmpdata)
        return tmpdata

    # 上传文件，需要注意的是data指文件内容，filename指保存在天河内部的文件名
    # PUT /api/file/<machine>/<path>
    def upload(self, myPath, filename, data):
        """ 上传文件到天河账户的工作区

        将data里面的数据保存到myPath中，文件名为filename

        返回值为是否成功（布尔型）
        """
        mheaders = {'Content-Type': "application/json"}
        tmpdata = self.open("/file/" + TH2_MACHINE_NAME + myPath + '/' + filename + '?overwrite=true', method="PUT",
                            data=data, headers=mheaders)

        th2_logger.debug("Upload returned data: %s" % tmpdata)
        return self.ret200()

    # 运行终端命令
    # POST  /api/command/<machine>
    def run_command(self, command, is_success=[False]):
        """ 发送终端命令到天河内部系统执行

        发送命令到天河内部系统的终端执行，is_success[0]表示是否成功

        返回值：
            0)正确，返回执行命令的输出（字符串）;
            1)命令本身出错，返回错误信息（字符串）;
            2)命令没有返回结果，返回none;
            3)请求出错，返回字符串
        """
        is_success[0] = False
        tmpdata = self.open("/command/" + TH2_MACHINE_NAME, data={"command": command})
        th2_logger.debug("run command return: %s", tmpdata)

        print type(tmpdata)
        # 返回结果正确
        if self.ret200() and tmpdata["retcode"] == 0:
            is_success[0] = True
            return tmpdata["output"]
        # 命令错误
        elif self.ret200():
            return tmpdata["error"]
            # 无返回结果
            # elif self.ret200():
            # return None
        # 请求错误
        else:
            return "Request fail."

    """
    上传多个文件
    """

    def upload_multi(self, myPath, problem_id, filename=[], data=[]):
        mkdir_command = "cd %s;if [ ! -d \"./%s\" ]; then mkdir \"./%s\"; fi" % (myPath, problem_id, problem_id)
        self.run_command(mkdir_command)

        for index in range(len(data)):
            if not self.upload(myPath + "/" + problem_id, filename[index], data[index]):
                return False
        return True

    """
    在当前评测目录编译程序
    """

    def mpi_complie(self, myPath, input_filename, output_filename):
        compile_command = "mpicc -O2 -o %s %s" % (output_filename, input_filename)
        commands = 'cd %s;%s' % (myPath, compile_command)

        compile_output = self.run_command(commands)
        print("Compile returned data: %s" % compile_output)

        compile_out = compile_output or "Compile success."
        if compile_output is None:
            compile_out = "Request fail."
        return compile_out

    """
    初始化编程题评测目录:根据已经上传到评测目录中的源代码文件来编译评测程序、参考程序等
    """

    def mpi_compile_multi(self, myPath, problem_id, input_filenames=[], output_filenames=[]):
        compile_out = ""
        for index in range(len(input_filenames)):
            output = self.mpi_complie(myPath + "/" + problem_id, input_filenames[index], output_filenames[index])
            compile_out = compile_out + "\n" + output
        return compile_out

    """
    在当前评测目录，根据用户代码运行评测程序
    """

    def mpi_run_multi(self, myPath, problem_id, user_id, output_filename, node_number=1,
                      task_number=1, step_num=1):
        sh_command = "cd %s;mpirun -np %s ./%s 1 %s %s" % ((myPath + "/" + problem_id + "/" + user_id), node_number,
                                                           output_filename, task_number, step_num)
        return self.run_command(sh_command)

    """
    建立编程题的评测目录
    """

    def create_program_dir(self, myPath, program_id):
        mkdir_command = "cd %s;mkdir %s" % (myPath, program_id)
        self.run_command(mkdir_command)

    """
    删除编程题的评测目录
    """

    def del_program_dir(self, myPath, program_id):
        mkdir_command = "cd %s;if [ -d \"./%s\" ]; then rm -rf \"./%s\"; fi" % (myPath, program_id, program_id)
        self.run_command(mkdir_command)


def extract_data(raw_data):
    lines = raw_data.split('\n')
    result = dict()
    result['picture_data'] = dict()
    count = 0
    thread_num = 0
    flag = True

    result['output'] = ""

    for line in lines:
        if line == "-------------------------------------------------------------------------------":
            if count == 0:
                count += 1
            elif count == 1:
                count += 1
            elif count == 2:
                count = 1
                thread_num += 1
                flag = True
            else:
                pass
        else:
            if count == 0:
                result['output'] += line + '\n'
            elif count == 1:
                result['picture_data'][str(thread_num)] = dict()
                result['picture_data'][str(thread_num)]['thread_name'] = line[line.find(':'):]
            elif count == 2:
                if flag:
                    # words = line.split(' ')

                    # for word in words:
                    #   result['picture_data'][str(thread_num)][word] = []
                    result['picture_data'][str(thread_num)]['excl.secs'] = []
                    flag = False
                else:
                    words = line.split(' ')

                    for word in words:
                        if word != '':
                            result['picture_data'][str(thread_num)]['excl.secs'].append(word)
                            break
            else:
                pass

    return result


def submit_code_new(pid, uid, source_code, task_number, cpu_number_per_task, language, ifEvaluate='0',
                    is_success=[False]):
    """ 后台提交从前端获取的代码到天河系统，编译运行并返回结果

    @pid: 编程题ID（对于非编程题的代码，可自行赋予ID）,
    @uid: 用户ID,
    @source_code: 所提交的代码文本,
    @task_number: 任务数,
    @cpu_number_per_task: CPU/任务比,
    @node_number: 使用节点数,
    @language: 语言;

    返回一个字典, 保存此次运行结果。
    """

    input_filename = "%s_%s.c" % (str(pid), str(uid))

    mc = ehpc_client_new()

    if not mc.upload(TH2_MY_PATH_NEW, input_filename, source_code):
        print "Upload fail."
        pass

    if language == "mpi":
        parameter_number = task_number
        parameter_language = "c.mpi"
    elif language == "openmp":
        parameter_number = cpu_number_per_task
        parameter_language = "c.omp"
    else:
        parameter_number = task_number # both are ok
        parameter_language = "c.cpp"
        ifEvaluate = '0'

    if ifEvaluate == '1':
        sh_command = "cd %s;./%s %s %s %s" % (
        TH2_MY_PATH_NEW, "comprun_tau.sh", input_filename, parameter_language, parameter_number)
    else:
        sh_command = "cd %s;./%s %s %s %s" % (
        TH2_MY_PATH_NEW, "comprun_with_no_evaluate.sh", input_filename, parameter_language, parameter_number)

    run_out_raw = mc.run_command(sh_command)

    # print run_out_raw
    result = dict()
    #print(language)

    if language == "mpi" and ifEvaluate == '1':
        run_out = extract_data(run_out_raw)
        result['run_out'] = run_out['output']
        result['picture_data'] = run_out['picture_data']
    else:
        result['run_out'] = run_out_raw

    is_success[0] = True
    result['status'] = 'success'
    result['problem_id'] = pid

    # print(result['picture_data'])

    return jsonify(**result)


def init_evaluate_program(problem_id, input_filenames=[], input_data=[], output_filenames=[]):
    """
    初始化评测程序，包括建立编程题文件夹、以及对评测程序和参考程序进行编译,编译后删除源文件
    默认提交的程序文件名分别为PI.cpp、program.cpp、ref.cpp、serial.cpp、hello.cpp
    默认输出的编译文件名分别为PI、program、ref、serial、hello
    """
    myPath = TH2_MY_PATH_NEW
    client = ehpc_client_new()
    client.del_program_dir(myPath, problem_id)
    client.create_program_dir(myPath, problem_id)

    if not client.upload_multi(myPath, problem_id, input_filenames, input_data):
        print("upload failed")
        exit(-1)
    print "upload success"

    print client.mpi_compile_multi(myPath, problem_id, input_filenames, output_filenames)

    rm_command = "cd %s; rm *.cpp" % (myPath + "/" + problem_id)
    client.run_command(rm_command)
    return True


def del_evaluate_program(myPath, problem_id):
    """
    删除评测目录
    """
    client = ehpc_client_new()
    client.del_program_dir(myPath, problem_id)


def run_evaluate_program(problem_id, user_id, input_code, cpu_num, step_num):
    """
    用户提交自己的代码参与评测，并返回评测结果
    (用户提交代码的默认文件名为 program.cpp 输出编译文件名为 program)
    """
    myPath = TH2_MY_PATH_NEW
    client = ehpc_client_new()
    # 若有原用户文件夹则删除
    rm_command = "cd %s;if [ -d \"./%s\" ]; then rm -rf \"./%s\"; fi" % (myPath + "/" + problem_id, user_id, user_id)
    client.run_command(rm_command)
    # 新建用户文件夹
    mkdir_command = "cd %s;if [ ! -d \"./%s\" ]; then mkdir \"./%s\"; fi" % (
        myPath + "/" + problem_id, user_id, user_id)
    client.run_command(mkdir_command)
    # 复制公用编译文件到用户文件夹
    cp_command = "cd %s;cp ../* ./" % (myPath + "/" + problem_id + "/" + user_id)
    client.run_command(cp_command)
    # 上传用户程序到用户文件夹
    if not client.upload(myPath + "/" + problem_id + "/" + user_id, "program.cpp", input_code):
        print("upload failed")
        exit(-1)
    print "user code upload success"
    # 编译用户程序
    client.mpi_complie(myPath + "/" + problem_id + "/" + user_id, "program.cpp", "program")
    # 提交运行脚本与用户程序
    result = client.mpi_run_multi(myPath=myPath, problem_id=problem_id, user_id=user_id,
                                  output_filename="PI", task_number=cpu_num, step_num=step_num)
    return result


"""提交并行代码以及对应评测程序，提交时本地目录下需有对应的文件，并设置好本地参数
"""


def test(name):
    global TH2_MY_PATH, TH2_BASE_URL, TH2_USERNAME, TH2_PASSWORD, TH2_MACHINE_NAME, TH2_LOGIN_DATA
    TH2_BASE_URL = TH2_BASE_URL_NEW
    TH2_USERNAME = TH2_USERNAME_NEW
    TH2_PASSWORD = TH2_PASSWORD_NEW
    TH2_MACHINE_NAME = TH2_MACHINE_NAME_NEW
    TH2_MY_PATH = TH2_MY_PATH_NEW
    TH2_LOGIN_DATA = TH2_LOGIN_DATA_NEW

    mc = ehpc_client_new()

    input_filename = "newtest.c"
    output_filename = "newtest.out"

    text = open("mpicc_demo.c").read()

    for i in range(10):
        print "%s: %d" % (name, i)
        print datetime.now()
        if not mc.upload(TH2_MY_PATH_NEW, input_filename, text):
            print "Upload fail."
            pass

            # compile_out = mc.ehpc_compile([True], TH2_MY_PATH_NEW, input_filename, output_filename, "mpi")
            # run_out = mc.ehpc_run(output_filename, TH2_MY_PATH_NEW, 4, 1, 1)
        sh_command = "cd %s;./%s %s %s %s" % (TH2_MY_PATH_NEW, "comprun.sh", input_filename, "c.mpi", "4")
        run_out = mc.run_command(sh_command)

        # print compile_out
        print run_out
        print datetime.now()


if __name__ == '__main__':
    try:
        a = threading.Thread(target=test, args=("a"))
        b = threading.Thread(target=test, args=("b"))
        c = threading.Thread(target=test, args=("c"))
        d = threading.Thread(target=test, args=("d"))
        e = threading.Thread(target=test, args=("e"))

        a.start()
        b.start()
        c.start()
        d.start()
        e.start()

        a.join()
        b.join()
        c.join()
        d.join()
        e.join()
    except:
        print "error thread"
    """
input_filename_1 = "hello.cpp"
    input_filename_2 = "ref.cpp"
    input_filename_3 = "serial.cpp"
    input_PI = "PI.cpp"

    output_filename_1 = "hello"
    output_filename_2 = "ref"
    output_filename_3 = "serial"
    output_PI = "PI"

    input_text_1 = open(input_filename_1).read()
    input_text_2 = open(input_filename_2).read()
    input_text_3 = open(input_filename_3).read()
    input_text_PI = open(input_PI).read()

    input_files = [input_filename_1, input_filename_2, input_filename_3, input_PI]
    output_files = [output_filename_1, output_filename_2, output_filename_3, output_PI]
    input_data = [input_text_1, input_text_2, input_text_3, input_text_PI]

    input_user = "program.cpp"
    output_user = "program"
    input_text_user = open(input_user).read()

    job_filename = "job.sh"

    init_evaluate_program('233', input_files, input_data, output_files)
    run_evaluate_program('233', 'zzp', input_text_user)
"""
