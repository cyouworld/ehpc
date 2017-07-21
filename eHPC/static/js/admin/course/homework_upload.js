$(document).ready(function () {
    var up_table = $('#homework-uploaded-table').DataTable({
        language: {
            url: "//cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Chinese.json"
        },
        "order": [[4, 'dec']],
        "pageLength": 100,
        "lengthMenu": [[ 10, 30, 50, 100, -1],[ 10, 30, 50, 100, '全部']]
    });
    $("#all-homework-select").click(function () {
        var obj = this;
        $("#homework-table-body").find("input[type=checkbox]").prop("checked", $(obj).prop("checked"));
    });

    var array = [];
    $("#del-homework-btn").click(function () {
        array = [];
        $("#homework-table-body").find("input").each(function () {
            if (this.checked) {
                array.push($(this).parent().parent().data("upload_id"));
            }
        });
        if (array.length == 0) {
            alert_modal("请勾选要删除的文件");
        }
        else {
            $("#del-warning").modal("show");
        }
    });

    $("#del-confirm").click(function () {
        $("#del-warning").modal("hide");
        $.ajax({
            type: "post",
            url: location.href,
            data: {
                op: "del",
                upload_id: array
            },
            success: function (data) {
                if(data.status=="success"){
                    $("#homework-table-body").find("input").each(function () {
                        if (this.checked) {
                            up_table.row($(this).parent().parent()).remove();
                            up_table.draw();
                        }
                    });
                    $("#homework-manage-panel").find("input").prop("checked", false);
                }
                else{
                    location.reload();
                }
            }
        });
    });

    $("#download-homework-btn").click(function () {
        array = [];
        $("#homework-table-body").find("input[type='checkbox']").each(function () {
            if (this.checked) {
                array.push($(this).parent().parent().data("upload_id"));
            }
        });
        if (array.length == 0) {
            alert_modal("请选择要下载的文件！");
        }

        else {
            $.ajax({
                type: "post",
                url: location.href,
                data: {
                    op: "download",
                    upload_id: array
                },
                success: function (data) {
                    if(data.status=="success"){
                        $("#homework-manage-panel").find("input").prop("checked", false);
                        var zip_path = $("input[name='zip-path']").val();
                        var a = document.createElement('a');
                        a.href = zip_path;
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

                            a.download = '' + data['course_title'] + '_' + data['homework_title'] + '_' + cur_year
                                + cur_month + cur_day + '-' + cur_hour + '-' + cur_min + '.zip';
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
                        $("#all-homework-select").prop("checked", "");
                        $("#homework-table-body").find("input[type=checkbox]").prop("checked", "");
                    }
                },
                error: function() {
                    alert_modal("文件下载失败");
                }
            });
        }
    });
});
