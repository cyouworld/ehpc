/**
 * Created by YM on 2017/7/15.
 */
var obj = null;
$("#homework-item-list").find("a[name=del-btn]").click(function () {
    obj = this;
    $("#del-warning").modal("show");
});

$("#del-confirm").click(function () {
    $.ajax({
        type: "post",
        url: location.href,
        data: {
            op: 'del',
            homework_id: $(obj).parent().parent().data('homework_id')
        },
        async: false,
        success: function (data) {
            if (data["status"] == "success") {
                $(obj).parent().parent().remove();
                $("#del-warning").modal("hide");
            }
            else {
                alert_modal("删除失败，请刷新后重试！");
                setTimeout(function() {$("#modal-alert").modal("hide");}, 1500);
            }
        }
    });
});

$("#search-unupload-btn").click(function() {
    var stu_info = $("#search-unupload-info").val();
    $.ajax({
        type: "post",
        url: location.href,
        data: {
            op: "search",
            stu_info: stu_info
        },
        async: false,
        success: function (data) {
            if (data["status"] == "success") {
                $("#student-name")[0].innerHTML = data['stu_name'];
                var unupload_list = data['not_upload'];
                var html_content ="";
                var tmp = "";
                for (var i=0;i<unupload_list.length;++i) {
                    tmp = "<li><i class='glyphicon glyphicon-star'></i> " + unupload_list[i] + "</li>";
                    html_content += tmp;
                }
                $("#unupload-list")[0].innerHTML = html_content;
                $("#myModal").modal("show");
            }
            else {
                alert_modal("查询失败，请稍后重试！");
                setTimeout(function() {$("#modal-alert").modal("hide");}, 1500);
            }
        },
        error: function () {
            alert_modal("查询失败，请稍后重试！");
            setTimeout(function() {$("#modal-alert").modal("hide");}, 1500);
        }
    });
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