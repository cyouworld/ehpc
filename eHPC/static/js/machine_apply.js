/**
 * Created by YM on 2017/6/10.
 */

$(function() {
    $("[data-toggle='tooltip']").tooltip();

    $(".list-group .list-group-item").click(function() {
        $(".list-group .list-group-item").removeClass("active");
        $(this).addClass("active");
    });
});