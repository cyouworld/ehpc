/**
 * Created by YM on 2017/6/10.
 */

$(function() {
    $("[data-toggle='tooltip']").tooltip();

    $(".list-group .list-group-item").click(function() {
        $(".list-group .list-group-item").removeClass("active");
        $(this).addClass("active");
        var option = $(this).data('option');
        $.ajax({
            type: "post",
            url: location.href,
            data: {
                op: option
            },
            async: false,
            success: function (data) {
                if (data["status"] == "success") {
                    $("#apply-issue-box")[0].innerHTML = data['html'];
                }
                else {
                    alert_modal("加载失败，请刷新后重试！");
                    setTimeout(function() {$("#modal-alert").modal("hide");}, 1500);
                }
            }
        });
    });
});