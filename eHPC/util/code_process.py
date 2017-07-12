#! /usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: xuezaigds@gmail.com
import json
import logging
import re
import time
import urllib
import urllib2

from flask import jsonify

from config import TH2_MAX_NODE_NUMBER, TH2_BASE_URL, TH2_ASYNC_WAIT_TIME, TH2_LOGIN_DATA, TH2_MACHINE_NAME, \
    TH2_DEBUG_ASYNC, TH2_MY_PATH, TH2_ASYNC_FIRST_WAIT_TIME, TH2_ASYNC_URL, TH2_LOGIN_URL, \
    TH2_BASE_URL_NEW, TH2_USERNAME_NEW, TH2_PASSWORD_NEW, TH2_MACHINE_NAME_NEW, TH2_MY_PATH_NEW, TH2_LOGIN_DATA_NEW

th2_logger = logging.getLogger('th2')
th2_logger.setLevel(logging.DEBUG)
file_handler = logging.FileHandler('app_logs/TH2.log')
file_handler.setLevel(logging.DEBUG)
file_handler.setFormatter(logging.Formatter('%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s'))
th2_logger.addHandler(file_handler)

global g__cookies
global TH2_MY_PATH, TH2_BASE_URL, TH2_USERNAME, TH2_PASSWORD, TH2_MACHINE_NAME, TH2_LOGIN_DATA


# 完成天河2号接口的功能的客户端
class ehpc_client:
    def __init__(self, base_url=TH2_BASE_URL, headers={}, login_cookie=None, login_data=TH2_LOGIN_DATA):
        global TH2_MY_PATH, TH2_BASE_URL, TH2_USERNAME, TH2_PASSWORD, TH2_MACHINE_NAME, TH2_LOGIN_DATA

        self.headers = headers
        self.base_url = TH2_BASE_URL
        self.login_cookie = login_cookie
        self.login_data = TH2_LOGIN_DATA
        self.async_wait_time = TH2_ASYNC_WAIT_TIME
        self.username = None
        global g__cookies

        try:
            if 'cookie' in g__cookies:
                pass
                if self.login_data == None:
                    self.login_data = g__cookies['cookie']
        except NameError:
            g__cookies = {}

    def open(self, url, data=None, method=None, login=True, async_get=True, async_wait=True, retjson=True):
        """ 入口函数，完成接收前端数据-发送请求到特定api接口-接收并保存返回数据的功能

        将接收的字典格式数据data封装进request请求，根据url参数发送到对应的api接口的地址，并对返回的数据进行
        处理以及保存。中间会根据参数对是否登录以及异步获取进行判断。

        返回值为一个字典，即api接口返回的数据。
        """

        url = self.base_url + url

        # 请求数据中带有查询字典或者form表单时，将其封装为 application/x-www-form-urlencoded string类型。
        # 如果请求数据为 unicode类型（上传的代码），则将其编码为 utf-8, 转为 str 类型。
        # https://docs.python.org/2/library/urllib.html#urllib.urlencode
        if data:
            try:
                if method != 'PUT':
                    data = urllib.urlencode(data).encode(encoding='UTF8')
                else:
                    data = data.encode('utf-8')
            except TypeError as ex:
                th2_logger.debug(data)
                th2_logger.debug(ex)
                pass

            # https://docs.python.org/2/library/urllib2.html#urllib2.Request
            # Data may be a string specifying additional data to send to the server
            req = urllib2.Request(url, data)
        else:
            req = urllib2.Request(url)

        # 如果需要登录权限，则查看请求中是否需要 cookie 。如果没有cookie，则调用login函数登录并保存cookie数据
        if login:
            if not self.login_cookie:
                self.login()

            req.add_header("Cookie", self.login_cookie)

        # 添加其他头部信息
        for (k, v) in self.headers:
            req.add_header(k, v)

        # 设置请求方法
        if method:
            req.get_method = lambda: method

        # 发送请求，请接受返回数据
        try:
            resp = urllib2.urlopen(req)
            self.resp = resp
            rdata = resp.read()
        except urllib2.HTTPError, e:  # HTTPError必须排在URLError的前面
            # print "The server couldn't fulfill the request.  Error code:", e.code
            th2_logger.debug("The server couldn't fulfill the request.  Error code:", e.code)
            rdata = e.read()
        except urllib2.URLError, e:
            self.status_code = 500
            self.status = "ERROR"
            # print "Failed to reach the server. The reason:", e.reason
            th2_logger.debug("Failed to reach the server. The reason:", e.reason)
            rdata = e.read()

        if not retjson:
            th2_logger.debug(dict(resp))
            self.data = rdata
            self.status_code = self.resp.code
            self.status = "OK" if resp.code == 200 else "ERROR"
            self.output = self.data
            return self.data

        if isinstance(rdata, bytes):
            rdata = rdata.decode('utf-8')
        rdata_reg = re.search('\{.+\}', rdata)
        rdata = rdata if rdata_reg is None else rdata_reg.group()

        # 保存数据
        try:
            if rdata_reg is None:
                self.data = rdata
                self.status_code = 200
                self.status = 200
            else:
                rdata = json.loads(rdata.decode('utf-8'))
                self.data = rdata
                self.status = self.data["status"]
                self.status_code = self.data["status_code"]
                self.output = self.data["output"]
        except ValueError as exc:
            # print(exc)
            th2_logger.debug("exe : %s" % exc)
            th2_logger.debug(("rdata : %s" % rdata))
            self.data = rdata
            try:
                self.status = self.data['status']
                self.status_code = self.data["status_code"]
            except Exception:
                self.status_code = 200
                self.status = 200
            self.status = "unknown"
        self.output = self.data
        if self.status_code == 200:
            self.status = "OK"

        # 如果开启了异步获取并且返回码是201,表示转入异步获取请求结果的状态
        if self.status_code == 201 and async_get:
            self.async_wait_time = TH2_ASYNC_FIRST_WAIT_TIME
            time.sleep(TH2_ASYNC_FIRST_WAIT_TIME)
            if TH2_DEBUG_ASYNC:
                pass
                th2_logger.debug("jump to async")
            th2_logger.debug(self.output)
            return self.open(TH2_ASYNC_URL + '/' + self.output["output"])

        # 如果返回码是100 continue并且设置了异步获取等待，继续请求
        if self.status_code == 100 and async_wait and self.async_wait_time > 0:
            time.sleep(1)
            self.async_wait_time -= 1
            if TH2_DEBUG_ASYNC:
                pass
                th2_logger.debug("async retry")
            return self.open(TH2_ASYNC_URL + '/' + self.output["output"])

        # 超时
        if self.async_wait_time <= 0:
            th2_logger.debug("Error: async connection time out.")
            self.async_wait_time = 5

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

    # 登录，返回值为是否成功（布尔型）
    # POST /api/auth
    def login(self):
        # print self.login_data
        tmpdata = self.open(TH2_LOGIN_URL, data=self.login_data, login=False)
        self.login_cookie = 'newt_sessionid=' + tmpdata["output"]["newt_sessionid"]
        self.username = self.login_data['username']
        global g__cookies

        try:
            g__cookies['cookie'] = self.login_cookie
        except NameError:
            g__cookies = {}
            g__cookies['cookie'] = self.login_cookie

        th2_logger.debug("Login returned data: %s" % tmpdata)

        return self.ret200()

    # 登出，返回值为是否成功（布尔型）
    # DELETE /api/auth
    def logout(self):
        self.open("/auth", login=True, method="DELETE")
        return self.ret200()

    # 暂时没有使用
    # GET /api/file/<machine>/<path>列目录
    def get_directory(self, myPath):
        tmpdata = self.open("/file/" + TH2_MACHINE_NAME + myPath + '/')
        return tmpdata['output']

    # GET /api/async/<id>获取
    def get_file(self, file_id):
        """ 通过异步方式获取文件内容

        根据文件名的id（通常是异步请求的输出）去获取文件内容

        返回值：成功则返回文件内容，否则返回none
        """
        tmpdata = self.open(TH2_ASYNC_URL + '/' + file_id)
        if self.ret200():
            return tmpdata["output"]["output"]
        else:
            return None

    # GET /api/file/<machine>/<path>?download=True
    def download(self, myPath, filename, isSmallApiServer=True, isjob=False):
        """ 下载给出路径中的文件内容，如果是脚本文件需要先对文件名进行处理

        首先对是否为脚本文件进行判断，然后获取文件的状态，从状态信息中取出保存结果的文件id

        最后获取结果文件

        返回的是输出结果（字符串）
        """
        if isjob:
            filename = "slurm-%s.out" % filename
        tmpdata = self.open("/file/" + TH2_MACHINE_NAME + myPath + '/' + filename + "?download=True")

        # print tmpdata
        if isSmallApiServer:
            tmpdata = tmpdata
        else:
            async_id = tmpdata["output"]
            # print async_id
            tmpdata = self.open("/file/" + TH2_MACHINE_NAME + "/%s?download=True" % async_id)
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
        tmpdata = self.open("/file/" + TH2_MACHINE_NAME + myPath + '/' + filename, method="PUT", data=data)

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

        # 返回结果正确
        if self.ret200() and isinstance(tmpdata, dict) and tmpdata["output"]["retcode"] == 0:
            is_success[0] = True
            return tmpdata["output"]["output"]
        # 命令错误
        elif self.ret200() and isinstance(tmpdata, dict):
            return tmpdata["output"]["error"]
        # 无返回结果
        elif self.ret200():
            return None
        # 请求错误
        else:
            return "Request fail."

    def submit_job(self, myPath, job_filename, output_filename, node_number=1, task_number=1, cpu_number_per_task=1,
                   partition="nsfc1"):
        """ 将需要执行的命令写成脚本文件并上传，最后将任务添加到超算中心的队列中

        @myPath: 编程题ID（对于非编程题的代码，可自行赋予ID）,
        @job_filename:
        @output_filename:
        @task_number: 任务数,
        @cpu_number_per_task: CPU/任务比,
        @node_number: 使用节点数,

        将接收的参数编写进运行脚本中，并将脚本文件上传到超算中心的账户中，最后将其添加到超算中心的任务队列中
        需要特别说明的是，现在这个函数的脚本只是用来运行文件的，并且一定不能修改它的缩进，否则无法正常运行。
        返回的是脚本任务在队列中的id（数字与字母组成的字符串）
        """

        jobscript = """#!/bin/bash
#SBATCH --partition=%s
#SBATCH --nodes=%s
#SBATCH --ntasks=%s
#SBATCH --cpus-per-task=%s
    srun ./%s
""" % (partition, node_number, task_number, cpu_number_per_task, output_filename)

        if not self.upload(myPath, job_filename, jobscript):
            return "ERROR"
        jobPath = myPath + "/" + job_filename
        tmpdata = self.open("/job/" + TH2_MACHINE_NAME + "/", data={"jobscript": jobscript, "jobfilepath": jobPath})

        th2_logger.debug("Submit job returned data: %s" % tmpdata)
        #th2_logger.debug("Submit job returned data url: %s" % TH2_BASE_URL)
        #th2_logger.debug("Submit job returned data machine: %s" % TH2_MACHINE_NAME)
        #th2_logger.debug("Submit job returned data partition: %s" % partition)

        return tmpdata["output"]["jobid"]

    def get_job_status(self, job_id):
        """
        获取脚本任务的状态

        :param job_id: 脚本任务的id，提交脚本函数的返回值
        :return:

        返回值目前有三个，分别为
        1. 排队中 Pending
        2. 运行中 Running
        3. 运行完毕 Finished

        需要注意的是，由于超算slurm系统的缘故，有时超算接口会在运行正常的时候返回Failed，所以在此将其列入Finished状态。
        """

        tmpdata = self.open("/job/" + TH2_MACHINE_NAME + "/" + str(job_id) + "/")

        th2_logger.debug("Get job status data: %s" % tmpdata)

        if tmpdata["status_code"] == 500 :
            return abort(500)

        times = 10
        while tmpdata["status_code"] == 100 and times > 0:
            times -= 1
            tmpdata = self.open(TH2_ASYNC_URL + '/' + self.output["output"])
        # print tmpdata

        if tmpdata["output"]["status"][str(job_id)] == "Success" or tmpdata["output"]["status"][str(job_id)] == "Failed":
            return "Finished"
        elif tmpdata["output"]["status"][str(job_id)] == "Pending":
            return "Pending"
        elif tmpdata["output"]["status"][str(job_id)] == "Running":
            return "Running"
        else:
            return "Getting job status fail."

    def ehpc_compile(self, is_success, myPath, input_filename, output_filename, language):
        """ 提交代码到天河内部系统编译

        根据参数决定编译命令，其中输入文件必须存在于给出的路径中，然后将编译命令作为参数，调用
        run_command函数进行编译

        返回值为字符串
        """
        compile_command = {
            "openmp": "g++ -fopenmp -o %s %s" % (output_filename, input_filename),
            "c++": "g++ -o %s %s" % (output_filename, input_filename),
            "mpi": "mpicc -o %s %s" % (output_filename, input_filename)
        }

        commands = 'cd %s;%s' % (myPath, compile_command[language])

        compile_output = self.run_command(commands, is_success)

        th2_logger.debug("Compile returned data: %s" % compile_output)

        compile_out = compile_output or "Compile success."

        if compile_output is None:
            compile_out = "Request fail."

        return compile_out

    def ehpc_run(self, output_filename, job_filename, myPath, task_number, cpu_number_per_task, node_number,
                 partition="nsfc1"):
        """ 在天河内部运行程序

        根据参数决定运行命令，其中文件必须存在于给出的路径中，调用提交脚本任务的函数submit_job()
        将运行任务提交到天河中，之后根据返回的id获取当前任务的状态，如果还在排队则继续等待
        否则则下载保存结果的文件并返回结果
        其中，task_number指任务的数量，cpu_number_per_task指每个任务分配到的核数
        node_number指天河执行任务的结点数，language指编译器，partition指天河内部执行的分区
        对于参数进一步的解释请参照天河用户手册返回值为运行文件的输出（字符串）
        """

        partition = "nsfc1"
        isSmallApiServer = False
        # print node_number
        if int(node_number) < 2:
            global TH2_MY_PATH, TH2_BASE_URL, TH2_USERNAME, TH2_PASSWORD, TH2_MACHINE_NAME, TH2_LOGIN_DATA
            TH2_BASE_URL = TH2_BASE_URL_NEW
            TH2_USERNAME = TH2_USERNAME_NEW
            TH2_PASSWORD = TH2_PASSWORD_NEW
            TH2_MACHINE_NAME = TH2_MACHINE_NAME_NEW
            TH2_MY_PATH = TH2_MY_PATH_NEW
            TH2_LOGIN_DATA = TH2_LOGIN_DATA_NEW
            isSmallApiServer = True
            partition = "debug"
            # print "Now is new Api server."
            # print "node number is %d" % int(node_number)
        elif int(node_number) > TH2_MAX_NODE_NUMBER:
            # print "Big job"
            partition = "BIGJOB1"

        jobid = self.submit_job(myPath, job_filename, output_filename, node_number=node_number, task_number=task_number,
                                cpu_number_per_task=cpu_number_per_task, partition=partition)

        if jobid == "ERROR":
            run_out = "Upload job file fail."
            return run_out

        time.sleep(0.2)

        job_status = self.get_job_status(jobid)

        # print tmpdata
        while True:
            if job_status == "Finished":
                break

            time.sleep(0.2)
            job_status = self.get_job_status(jobid)
            # print job_status

        run_output = self.download(myPath, jobid, isSmallApiServer=isSmallApiServer, isjob=True)
        run_out = run_output or "No output."

        if run_output is None:
            run_out = "Request error."

        return run_out

    def upload_multi(self, myPath, problem_id, filename=[], data=[]):

        mkdir_command = "cd %s;if [ ! -d \"./%s\" ]; then mkdir \"./%s\"; fi" % (myPath, problem_id, problem_id)

        output = self.run_command( mkdir_command )

        for index in range( len(data) ) :
            if not self.upload(myPath + "/" + problem_id, filename[index], data[index]):
                return False
        return True

    """
    在当前评测目录编译mpi程序
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

    def submit_job_multi(self, myPath, problem_id, user_id, job_filename, output_filename, node_number=1,
                         task_number=1, step_num=1, partition="nsfc1"):
        jobscript = """#!/bin/bash
#SBATCH --partition=%s
#SBATCH --nodes=%s
    ./%s 1 %s %s
""" % (partition, node_number, output_filename, task_number, step_num)

        #print jobscript

        if not self.upload(myPath + "/" + problem_id + "/" + user_id, job_filename, jobscript):
            return "ERROR"

        jobPath = myPath + "/" + problem_id + "/" + user_id + "/" + job_filename

        tmpdata = self.open("/job/" + TH2_MACHINE_NAME + "/", data={"jobscript": jobscript, "jobfilepath": jobPath})
        #print tmpdata
        return tmpdata["output"]["jobid"]

    """
    建立编程题的评测目录
    """
    def create_program_dir(self, myPath, program_id):
        mkdir_command = "cd %s;mkdir %s" % (myPath, program_id)
        self.run_command( mkdir_command )

    """
    删除编程题的评测目录
    """
    def del_program_dir(self, myPath, program_id):
        mkdir_command = "cd %s;if [ -d \"./%s\" ]; then rm -rf \"./%s\"; fi" % (myPath, program_id, program_id)
        self.run_command( mkdir_command )


def submit_code(pid, uid, source_code, task_number, cpu_number_per_task, node_number, language, op, jobid,
                compile_success=[False]):
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

    job_filename = "%s_%s.sh" % (str(pid), str(uid))
    input_filename = "%s_%s.c" % (str(pid), str(uid))
    output_filename = "%s_%s.o" % (str(pid), str(uid))

    partition = "nsfc1"
    isSmallApiServer = False
    # print node_number
    if int(node_number) < 2:
        global TH2_MY_PATH, TH2_BASE_URL, TH2_USERNAME, TH2_PASSWORD, TH2_MACHINE_NAME, TH2_LOGIN_DATA
        TH2_BASE_URL = TH2_BASE_URL_NEW
        TH2_USERNAME = TH2_USERNAME_NEW
        TH2_PASSWORD = TH2_PASSWORD_NEW
        TH2_MACHINE_NAME = TH2_MACHINE_NAME_NEW
        TH2_MY_PATH = TH2_MY_PATH_NEW
        TH2_LOGIN_DATA = TH2_LOGIN_DATA_NEW
        isSmallApiServer = True
        partition = "debug"
        # print "Now is new Api server."
        # print "node number is %d" % int(node_number)
    elif int(node_number) > TH2_MAX_NODE_NUMBER:
        # print "Big job"
        partition = "BIGJOB1"

    client = ehpc_client()
    is_success = [False]

    is_success[0] = client.login()
    if not is_success[0]:
        return jsonify(status="fail", msg="连接超算主机失败!")

    result = dict()

    if op == "1":
        is_success[0] = client.upload(TH2_MY_PATH, input_filename, source_code)

        job_status = "Compiling"

        if not is_success[0]:
            return jsonify(status="fail", msg="上传程序到超算主机失败!")

        compile_out = client.ehpc_compile(is_success, TH2_MY_PATH, input_filename, output_filename, language)

        compile_success = is_success

        if is_success[0]:
            result['isSuccess'] = 'true'
        else:
            result['isSuccess'] = 'false'

        if is_success[0]:

            jobid = client.submit_job(TH2_MY_PATH, job_filename, output_filename, node_number=node_number,
                                      task_number=task_number,
                                      cpu_number_per_task=cpu_number_per_task, partition=partition)

            run_out = "脚本任务排队中，请稍候！"
        else:
            run_out = "编译失败，无法运行！"

        result['compile_out'] = compile_out
        result['run_out'] = run_out

    elif op == "2":
        if jobid == "ERROR" or jobid == -1:
            run_out = "Upload job file fail."
            # return run_out
        else:
            time.sleep(0.2)

            job_status = client.get_job_status(jobid)

            # print tmpdata
            while True:
                if job_status == "Finished":
                    break

                time.sleep(0.2)
                job_status = client.get_job_status(jobid)
                # print job_status

            run_output = client.download(TH2_MY_PATH, jobid, isSmallApiServer=isSmallApiServer, isjob=True)
            run_out = run_output or "No output."

            if run_output is None:
                run_out = "Request error."

        result['run_out'] = run_out

    elif op == "3":
        job_status = client.get_job_status(jobid)
        result['job_status'] = job_status

    result['status'] = 'success'
    result['problem_id'] = pid
    result['job_id'] = jobid

    return jsonify(**result)


def init_evaluate_program(problem_id, input_filenames=[], input_data=[], output_filenames=[]):
    """
    初始化评测程序，包括建立编程题文件夹、以及对评测程序和参考程序进行编译,编译后删除源文件
    默认提交的程序文件名分别为PI.cpp、program.cpp、ref.cpp、serial.cpp、hello.cpp
    默认输出的编译文件名分别为PI、program、ref、serial、hello
    """
    myPath = TH2_MY_PATH
    client = ehpc_client()
    if not client.login():
        return jsonify(status="fail", msg="连接超算主机失败!")
    #print "login success"

    client.del_program_dir(myPath, problem_id)
    client.create_program_dir(myPath, problem_id)

    if not client.upload_multi(myPath, problem_id, input_filenames, input_data):
        #print("upload failed")
        exit(-1)
    #print "upload success"

    #print client.mpi_compile_multi(myPath, problem_id, input_filenames, output_filenames)

    rm_command = "cd %s; rm *.cpp" % (myPath + "/" + problem_id)
    client.run_command( rm_command )
    return True


def del_evaluate_program(myPath, problem_id):
    """
    删除评测目录
    """
    client = ehpc_client()
    if not client.login():
        return jsonify(status="fail", msg="连接超算主机失败!")
    #print "login success"
    client.del_program_dir(myPath, problem_id)


def run_evaluate_program(problem_id, user_id, input_code, cpu_num, step_num):
    """
    用户提交自己的代码参与评测，并返回评测结果
    (用户提交代码的默认文件名为 program.cpp 输出编译文件名为 program
    评测默认运行脚本名为 job.sh)
    """
    myPath = TH2_MY_PATH
    client = ehpc_client()
    if not client.login():
        return jsonify(status="fail", msg="连接超算主机失败!")
    #print "login success"
    # 若有原用户文件夹则删除
    rm_command = "cd %s;if [ -d \"./%s\" ]; then rm -rf \"./%s\"; fi" % (myPath + "/" + problem_id, user_id, user_id)
    #print client.run_command( rm_command )
    # 新建用户文件夹
    mkdir_command = "cd %s;if [ ! -d \"./%s\" ]; then mkdir \"./%s\"; fi" % (myPath + "/" + problem_id, user_id, user_id)
    #print client.run_command( mkdir_command )
    # 复制公用编译文件到用户文件夹
    cp_command = "cd %s;cp ../* ./" % (myPath + "/" + problem_id + "/" + user_id )
    #print client.run_command( cp_command )
    # 上传用户程序到用户文件夹
    if not client.upload(myPath + "/" + problem_id + "/" + user_id, "program.cpp", input_code):
        #print("upload failed")
        exit(-1)
    #print "user code upload success"
    # 编译用户程序
    #print client.mpi_complie(myPath + "/" + problem_id + "/" + user_id, "program.cpp", "program")
    # 提交运行脚本与用户程序
    job_id = client.submit_job_multi(myPath, problem_id, user_id, "job.sh", "PI", 1, cpu_num, step_num, "debug")
    #print client.get_job_status(job_id)
    # 下载运行结果
    time.sleep(4)
    run_output = client.download(myPath + "/" + problem_id + "/" + user_id, job_id, isSmallApiServer=True, isjob=True)
    return run_output


"""提交并行代码以及对应评测程序，提交时本地目录下需有对应的文件，并设置好本地参数
"""
if __name__ == '__main__':

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
