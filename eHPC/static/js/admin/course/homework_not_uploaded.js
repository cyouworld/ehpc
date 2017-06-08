/**
 * Created by YM on 2017/6/8.
 */
$(document).ready(function () {
    var up_table = $('#homework-correct-table').DataTable({
        language: {
            url: "//cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Chinese.json"
        },
        "order": [[0, 'asc']],
        "lengthMenu": [[ 10, 30, 50, 100, -1],[ 10, 30, 50, 100, 'ALL']]
    });

    $("#download-list-btn").click(function () {
        $.ajax({
            type: "post",
            url: location.href,
            success: function (data) {
                if(data.status=="success"){
                    var score_path = $("input[name='list-path']").val();
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
                alert_modal("名单导出失败");
                setTimeout(function() {$("#modal-alert").modal("hide");}, 1500);
            }
        });
    });
});