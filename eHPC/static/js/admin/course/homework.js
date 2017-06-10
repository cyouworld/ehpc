function delete_appendix(e) {
    var event = e || window.event;
    var curr_ele = event || event.srcElement;
    var curr_div = curr_ele.parentNode.parentNode;
    if (curr_div.classList.contains("uploaded")) {
        var appendix_id = curr_div.getAttribute("data-appendix-id");
        $.ajax({
            type: "post",
            url: location.href,
            data: {
                op: "del",
                appendix_id: appendix_id
            },
            success: function (data) {
                if(data.status == "success"){
                    curr_div.remove();
                }
                else{
                    var str = curr_div.data("appendix-name") + "删除失败，请稍后重试！";
                    alert_modal(str);
                }
            }
        });
    }
}

$(document).ready(function () {
    $('#dtp').datetimepicker({
        format: "yyyy-mm-dd hh:ii",
        weekStart: 1,
        todayBtn:  1,
        autoclose: 1,
        todayHighlight: 1,
        startView: 2,
        forceParse: 0
    });

    edt.codemirror.on('refresh', function() {
        if (edt.isFullscreenActive()) {
            $('body').addClass('simplemde-fullscreen');
        }
        else {
            $('body').removeClass('simplemde-fullscreen');
        }
    });

    edt.codemirror.on("update", function() {
        $("#homework-description")[0].innerHTML = edt.value();
        if (edt.value()) {
            hide_validate_info("#content-errors");
        }
        else {
            $("#content-errors")[0].innerHTML = '<ul class="parsley-errors-list filled" style="color: red;" id="parsley-id-9"><li class="parsley-required">请输入作业内容</li></ul>';
        }
    });

    $("#save-homework-info").click(function() {
        $("#homework-save-op").val("save");
        var p_instance = $('#course-homework-form').parsley();
        p_instance.validate();
    });

    // Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
    var template = $("#template").parent().html();
    $("#template").remove();
    var error = false;
    $("#course-homework-form").dropzone({
        url: location.href,
        maxFiles: 10,
        maxFilesize: 50,
        acceptedFiles: "video/mp4,video/mkv,application/pdf,.zip,.rar",
        autoProcessQueue: true,
        previewTemplate: template,
        uploadMultiple: true,
        parallelUploads: 10,
        previewsContainer: "#previews", // Define the container to display the previews
        clickable: "#select-homework-appendix", // Define the element that should be used as click trigger to select files.
        dictInvalidFileType: "不支持的文件类型",
        dictMaxFilesExceeded: "文件数量不能超过10个",
        dictFileTooBig: "文件大小不能超过50M",
        init: function() {
            var myDropzone = this;
            this.on("addedfile", function(file) {
                $("#upload-status").show();
                $("#homework-save-op").val("upload");
            });
            this.on("error", function (file) {
               error = true;
            });
            this.on("successmultiple", function(file,response) {
                $("#homework-id").val(response.homework_id);
                $("#upload-status .close").click();
                for (var i=0;i<response.new_upload_id.length;++i) {
                    var uploadFilehtml;
                    uploadFilehtml = ''
                        + '<div id="appendix' + response.new_upload_id[i] + '" class="alert alert-success alert-dismissable uploaded" role="alert" data-appendix-name="'
                        + response.new_upload_name[i] + '" data-appendix-id="' + response.new_upload_id[i] + '">'
                        + '<button type="button" class="close" aria-label="Close">'
                        + '<span class="delete-appendix" aria-hidden="true" onclick="delete_appendix(this);">&times;</span></button>'
                        + '<i class="es-icon es-icon-description status-icon pull-left"></i>'
                        + '<a href="/static/homework/appendix/' + response.new_upload_uri[i] + '" download="'
                        + response.new_upload_name[i] + '">' + response.new_upload_name[i] + '</a>'
                        + '</div>';
                    $("#homework-appendix-list").append(uploadFilehtml);
                }
            });

            $("#upload-status #dialog-mini-btn").click(function () {
                $("#upload-status .modal-body").toggle();
            });
        },
        headers: {
            'X-CSRFToken': csrf_token
        }
    });

    $("#dialog-close-btn").click(function () {
        $("#upload-status").hide();
    });

});/**
 * Created by YM on 2016/12/26.
 */
