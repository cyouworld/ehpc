$(document).ready(function () {
    var up_table = $('#homework-correct-table').DataTable({
        language: {
            url: "//cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Chinese.json"
        },
        "order": [[0, 'asc']],
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
                        setTimeout(function() {$("#modal-alert").modal("hide");}, 1500);
                        location.reload();
                    }
                },
                error: function() {
                    alert_modal("成绩导入失败，请查看文件格式是否正确");
                    setTimeout(function() {$("#modal-alert").modal("hide");}, 1500);
                }
            });
        }
    });
});