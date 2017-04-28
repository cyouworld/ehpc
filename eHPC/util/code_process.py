#! /usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: xuezaigds@gmail.com
import urllib2, urllib
from config import TH2_MAX_NODE_NUMBER, TH2_BASE_URL, TH2_ASYNC_WAIT_TIME, TH2_LOGIN_DATA, TH2_MACHINE_NAME, TH2_DEBUG_ASYNC, TH2_MY_PATH, TH2_ASYNC_FIRST_WAIT_TIME, TH2_ASYNC_URL, TH2_LOGIN_URL
from flask import jsonify
import json
import time


# 完成天河2号接口的功能的客户端
class ehpc_client:
    def __init__(self, base_url=TH2_BASE_URL, headers={}, login_cookie=None, login_data=TH2_LOGIN_DATA):
        self.headers = headers
        self.base_url = base_url
        self.login_data = login_data
        self.async_wait_time = TH2_ASYNC_WAIT_TIME

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
                data = urllib.urlencode(data)
            except TypeError:
                data = data.encode('utf-8')             # Issue 470

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
            print "The server couldn't fulfill the request.  Error code:", e.code
            rdata = e.read()
        except urllib2.URLError, e:
            print "Failed to reach the server. The reason:", e.reason
            rdata = e.read()

        # 保存数据
        try:
            rdata = json.loads(rdata.decode('utf-8'))
            self.data = rdata
            self.status = self.data["status"]
            self.status_code = self.data["status_code"]
            self.output = self.data["output"]
        except ValueError:
            self.data = rdata
            try:
                self.status_code = resp.getcode()
            except Exception:
                self.status_code = 403
            self.status = "unknown"
            self.output = self.data
            if self.status_code == 200:
                self.status = "OK"

        # 如果开启了异步获取并且返回码是201,表示转入异步获取请求结果的状态
        if self.status_code == 201 and async_get:
            self.async_wait_time = 5
            time.sleep(TH2_ASYNC_FIRST_WAIT_TIME)
            if TH2_DEBUG_ASYNC:
                print "jump to async"
            return self.open(TH2_ASYNC_URL + '/' + self.output)

        # 如果返回码是100 continue并且设置了异步获取等待，继续请求
        if self.status_code == 100 and async_wait and self.async_wait_time > 0:
            time.sleep(1)
            self.async_wait_time -= 1
            if TH2_DEBUG_ASYNC:
                print "async retry"
            self.open(TH2_ASYNC_URL + '/' + self.output)

        # 超时
        if self.async_wait_time <= 0:
            print "Error: async connection time out."
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
        tmpdata = self.open(TH2_LOGIN_URL, data=self.login_data, login=False)
        self.login_cookie = 'newt_sessionid=' + tmpdata["output"]["newt_sessionid"]
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
    def download(self, myPath, filename, isjob=False):
        """ 下载给出路径中的文件内容，如果是脚本文件需要先对文件名进行处理

        首先对是否为脚本文件进行判断，然后获取文件的状态，从状态信息中取出保存结果的文件id

        最后获取结果文件

        返回的是输出结果（字符串）
        """
        if isjob:
            filename = "slurm-%s.out" % filename
        tmpdata = self.open("/file/" + TH2_MACHINE_NAME + myPath + '/' + filename + "?download=True")
        async_id = tmpdata["output"]
        # print async_id
        tmpdata = self.open("/file/" + TH2_MACHINE_NAME + "/%s?download=True" % async_id)
        return tmpdata

    # 上传文件，需要注意的是data指文件内容，filename指保存在天河内部的文件名
    # PUT /api/file/<machine>/<path>
    def upload(self, myPath, filename, data):
        """ 上传文件到天河账户的工作区

        将data里面的数据保存到myPath中，文件名为filename

        返回值为是否成功（布尔型）
        """
        tmpdata = self.open("/file/" + TH2_MACHINE_NAME + myPath + '/' + filename, method="PUT", data=data)
        # print tmpdata
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
        # print tmpdata
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

        if int(node_number) > TH2_MAX_NODE_NUMBER:
            partition = "BIGJOB1"

        jobscript = """#!/bin/bash
#SBATCH -p %s
#SBATCH -N %s
    yhrun -n %s -c %s ./%s
""" % (partition, node_number, task_number, cpu_number_per_task, output_filename)

        if not self.upload(myPath, job_filename, jobscript):
            return "ERROR"
        jobPath = myPath + "/" + job_filename
        tmpdata = self.open("/job/" + TH2_MACHINE_NAME + "/", data={"jobscript" : jobscript, "jobfilepath" : jobPath})
        return tmpdata["output"]["jobid"]

    def ehpc_compile(self, is_success, myPath, input_filename, output_filename, language):
        """ 提交代码到天河内部系统编译

        根据参数决定编译命令，其中输入文件必须存在于给出的路径中，然后将编译命令作为参数，调用
        run_command函数进行编译

        返回值为字符串
        """
        compile_command = {
            "openmp": "icc -openmp -o %s %s"%(output_filename, input_filename),
            "c++": "g++ -o %s %s" % (output_filename, input_filename),
            "mpi": "mpicc -o %s %s" % (output_filename, input_filename)
        }

        commands = 'cd %s;%s' % (myPath, compile_command[language])

        compile_output = self.run_command(commands, is_success)
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
        if int(node_number) > TH2_MAX_NODE_NUMBER:
            partition = "BIGJOB1"

        jobid = self.submit_job(myPath, job_filename, output_filename, node_number=node_number, task_number=task_number,
                                cpu_number_per_task=cpu_number_per_task, partition=partition)

        if jobid == "ERROR":
            run_out = "Upload job file fail."
            return run_out

        time.sleep(5)
        tmpdata = self.open("/job/" + TH2_MACHINE_NAME + "/" + str(jobid) + "/")
        # print tmpdata
        while True:
            if tmpdata["output"]["status"][jobid] == "Success" or tmpdata["output"]["status"][jobid] == "Failed":
                break

            time.sleep(5)
            tmpdata = self.open("/job/" + TH2_MACHINE_NAME + "/" + str(jobid) + "/")

        run_output = self.download(myPath, jobid, isjob=True)
        run_out = run_output or "No output."

        if run_output is None:
            run_out = "Request error."

        return run_out


def submit_code(pid, uid, source_code, task_number, cpu_number_per_task, node_number, language):
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

    client = ehpc_client()
    is_success = [False]

    is_success[0] = client.login()
    if not is_success[0]:
        return jsonify(status="fail", msg="连接超算主机失败!")

    is_success[0] = client.upload(TH2_MY_PATH, input_filename, source_code)
    if not is_success[0]:
        return jsonify(status="fail", msg="上传程序到超算主机失败!")

    compile_out = client.ehpc_compile(is_success, TH2_MY_PATH, input_filename, output_filename, language)

    if is_success[0]:
        run_out = client.ehpc_run(output_filename, job_filename, TH2_MY_PATH, task_number, cpu_number_per_task, node_number)
    else:
        run_out = "编译失败，无法运行！"

    result = dict()
    result['status'] = 'success'
    result['problem_id'] = pid
    result['compile_out'] = compile_out
    result['run_out'] = run_out

    return jsonify(**result)


if __name__ == '__main__':
    input_filename = "mpicc_demo.c"
    output_filename = "ab.out"
    # 上传的脚本文件名
    job_filename = "job.sh"

    mc = ehpc_client()
    test_text = open("mpicc_demo.c").read()

    if not mc.login():
        exit(-1)

    if not mc.upload(TH2_MY_PATH, input_filename, test_text):
        exit(-1)

    is_success = [False]
    compile_out = mc.ehpc_compile(is_success, TH2_MY_PATH, input_filename, output_filename, "mpi")
    print compile_out, type(compile_out)
    if not is_success[0]:
        exit(-1)
    run_out = mc.ehpc_run(output_filename, job_filename, TH2_MY_PATH, "4", "1", "2")
    print run_out, type(run_out)
