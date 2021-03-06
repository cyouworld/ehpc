$(document).ready(function () {
    var up_table = $('#homework-correct-table').DataTable({
        language: {
            url: "//cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Chinese.json"
        },
        "order": [[0, 'asc']],
        "pageLength": -1,
        "lengthMenu": [[ 10, 30, 50, 100, -1],[ 10, 30, 50, 100, '全部']]
    });

    $('.submit-score').click(function () {
        var score = $(this).parent().parent().find("input[name='homework-score']").val();
        if (!score) {
            alert_modal("分数不能为空");
            setTimeout(function() {$("#modal-alert").modal("hide");}, 1500);
        }
        else if (score < 0 || score >100) {
            alert_modal("分数应为0-100的数字");
            setTimeout(function() {$("#modal-alert").modal("hide");}, 1500);
        }
        else {
            var op = $(this).parent().parent().data("op");
            var user_id = $(this).parent().parent().data("user_id");
            var comment = $(this).parent().parent().find("input[name='homework-comment']").val();
            if (comment.length >1024) {
                alert_modal("评语不能超过1024个字");
                setTimeout(function() {$("#modal-alert").modal("hide");}, 1500);
            }
            else {
                $.ajax({
                    type: "post",
                    url: location.href,
                    data: {
                        op: op,
                        user_id: user_id,
                        homework_score: score,
                        homework_comment: comment
                    },
                    success: function (data) {
                        if (data["status"] == "success") {
                            alert_modal("成绩提交成功！");
                            setTimeout(function() {$("#modal-alert").modal("hide");}, 1500);
                            location.reload();
                        }
                        else {
                            alert_modal("成绩提交失败，请刷新后重试！");
                            setTimeout(function() {$("#modal-alert").modal("hide");}, 1500);
                        }
                    }
                });
            }
        }
    });

    var user_id_list = new Array(), scores = new Array(), comments = new Array();

    $("input[name='homework-score']").change(function () {
        var tmp_tr = $(this).parent().parent();
        var index = user_id_list.indexOf(tmp_tr.data("user_id"));
        if (index >= 0) {
            scores[index] = $(this).val();
            tmp_tr.find("input[name=homework-comment]").each(function () {
                comments[index] = $(this).val();
            });
        }
        else {
            user_id_list.push(tmp_tr.data("user_id"));
            scores.push($(this).val());
            tmp_tr.find("input[name=homework-comment]").each(function () {
                comments.push($(this).val());
            });
        }
    });

    $("input[name='homework-comment']").change(function () {
        var tmp_tr = $(this).parent().parent();
        var index = user_id_list.indexOf(tmp_tr.data("user_id"));
        if (index >= 0) {
            comments[index] = $(this).val();
            tmp_tr.find("input[name=homework-score]").each(function () {
                scores[index] = $(this).val();
            });
        }
        else {
            user_id_list.push(tmp_tr.data("user_id"));
            comments.push($(this).val());
            tmp_tr.find("input[name=homework-score]").each(function () {
                scores.push($(this).val());
            });
        }
    });

    $("#submit-score-btn").click(function () {
        if (user_id_list.length > 0) {
            for (var i=0;i<user_id_list.length;++i) {
                if (!scores[i]) {
                    alert_modal("分数不能为空！有些同学有评语但是没有分数，请检查后重新提交！");
                    return;
                }
            }
            $.ajax({
                type: "post",
                url: location.href,
                data: {
                    op: "submit-multi",
                    user_id_list: user_id_list,
                    scores: scores,
                    comments: comments
                },
                success: function (data) {
                    if (data["status"] == "success") {
                        alert_modal("成绩提交成功！");
                        setTimeout(function() {
                            $("#modal-alert").modal("hide");
                            location.reload();
                        }, 1500);
                    }
                    else {
                        alert_modal("成绩提交失败，请刷新后重试！");
                        setTimeout(function() {$("#modal-alert").modal("hide");}, 1500);
                    }
                }
            });
        }
    });

    $("#download-score-btn").click(function () {
        $.ajax({
            type: "post",
            url: location.href,
            data: {
                op: "download-score",
            },
            success: function (data) {
                if(data.status=="success"){
                    var score_path = $("input[name='score-path']").val();
                    var a = document.createElement('a');
                    a.href = score_path;
                    a.target = '_parent';
                    // Use a.download if available, it prevents plugins from opening.
                    if ('download' in a) {
                        var cur_time = new Date();
                        var cur_year = cur_time.getFullYear();
                        // 得到两位数的时间， 比如 20170302-11_01.zip
                        var cur_month = ("0" + (cur_time.getMonth() + 1)).slice(-2);
                        var cur_day = ("0" + cur_time.getDate()).slice(-2);
                        var cur_hour = ("0" + cur_time.getHours()).slice(-2);
                        var cur_min = ("0" + cur_time.getMinutes()).slice(-2);
                        a.download = '' + data['download_file_name'] + '_' + cur_year
                            + cur_month + cur_day + '-' + cur_hour + '-' + cur_min + '.xlsx';
                    }
                    // Add a to the doc for click to work.
                    (document.body || document.documentElement).appendChild(a);
                    if (a.click) {
                        a.click(); // The click method is supported by most browsers.
                    }
                    else {
                        $(a).click(); // Backup using jquery
                    }
                    // Delete the temporary link.
                    a.parentNode.removeChild(a);
                }
            },
            error: function() {
                alert_modal("文件下载失败");
                setTimeout(function() {$("#modal-alert").modal("hide");}, 1500);
            }
        });
    });

    $("#score-file").change(function () {
        alert_modal("成绩导入中，请稍后...");
        var p_instance = $('#score-file-form').parsley();
        p_instance.validate();
        if(p_instance.isValid()) {
            $.ajax({
                type: "post",
                url: location.href,
                data: new FormData($("#score-file-form")[0]),
                cache: false,
                contentType: false,
                processData: false,
                success: function (data) {
                    if(data.status=="success"){
                        alert_modal("成绩导入成功");
                        setTimeout(function() {
                            $("#modal-alert").modal("hide");
                            location.reload();
                        }, 1500);
                    }
                    else if(data.status=="partially"){
                        alert_modal("部分学生分数为空导入失败，其余导入成功!");
                        setTimeout(function() {
                            $("#modal-alert").modal("hide");
                            location.reload();
                        }, 1500);
                    }
                    else{
                        alert_modal("文件上传失败，请刷新后重试！");
                        setTimeout(function() {
                            $("#modal-alert").modal("hide");
                            location.reload();
                        }, 1500);
                    }
                },
                error: function(jqXHR, status, error) {
                    var msg = '';
                    if (jqXHR.status === 0) {
                        msg = 'Not connect.\n Verify Network.';
                    } else if (jqXHR.status == 404) {
                        msg = '请求页面找不到了. [404]';
                    } else if (jqXHR.status == 500) {
                        msg = '服务器错误 [500].';
                    } else if (exception === 'parsererror') {
                        msg = '请求数据转换错误.';
                    } else if (exception === 'timeout') {
                        msg = '请求超时.';
                    } else if (exception === 'abort') {
                        msg = '请求已放弃.';
                    } else {
                        msg = 'Uncaught Error.\n' + jqXHR.responseText;
                    }
                    alert_modal(msg);
                    setTimeout(function() {$("#modal-alert").modal("hide");}, 2000);
                }
            });
        }
    });
});