function delete_upload(e) {
    var event = e || window.event;
    var curr_ele = event || event.srcElement;
    var curr_div = curr_ele.parentNode.parentNode;
    var upload_id = curr_div.getAttribute("data-upload-id");
    $.ajax({
        type: "post",
        url: post_to,
        data: {
            op: "del",
            upload_id: upload_id
        },
        success: function (data) {
            if(data.status == "success"){
                curr_div.remove();
            }
            else{
                var str = curr_div.data("upload-name") + "删除失败，请稍后重试！";
                show_invalid_info("#homework-upload-status","#homework-upload-status",str);
            }
        }
    });
}

$(document).ready(function() {
    $('input[id=homework-file]').change(function() {
        $('#filenameCover').val($(this).val());
    });

    $("#return-homework-list").click(function() {
        $("#course-lists").removeClass('active');
        $("#course-about").removeClass('active');
        $('#course-test').removeClass('active');
        $('#course-comment').removeClass('active');
        $('#course-homework').addClass('active');
        /* 加载作业列表内容 */
        $.ajax({
            url: back_to_list,
            dataType: "json",
            contentType: 'application/json;charset=UTF-8',
            success: function (html) {
                $("#course-homework").empty().html(html.data);
            },
            error: function () {
                $("#course-homework").empty().html("<h2 style='text-align: center'> 作业内容为空或者出现其他错误 </h2>");
            }
        });
    });

    // Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
    var template = $("#template").parent().html();
    $("#template").remove();
    var error = false;
    $("#homework-file-form").dropzone({
        url: post_to,
        maxFiles: 10,
        maxFilesize: 50,
        acceptedFiles: "application/pdf,.zip,.rar",
        autoProcessQueue: true,
        previewTemplate: template,
        uploadMultiple: true,
        parallelUploads: 10,
        previewsContainer: "#previews", // Define the container to display the previews
        clickable: "#select-homework-files", // Define the element that should be used as click trigger to select files.
        dictInvalidFileType: "不支持的文件类型",
        dictMaxFilesExceeded: "文件数量不能超过10个",
        dictFileTooBig: "文件大小不能超过50M",
        init: function() {
            var myDropzone = this;
            this.on("addedfile", function(file) {
                //$("#upload-status").show();
                $("#upload-status").modal('show');
                $(".file-remove").hide();
                $("#upload-status").css("top","30%");
                $("#upload-status").css("left","30%");
                $("#upload-status").css("bottom","auto");
            });
            this.on("error", function (file) {
               error = true;
            });
            this.on("successmultiple", function(file,response) {
                if (response.status == "failed") {
                    myDropzone.removeAllFiles();
                    $("#upload-status .dz-complete").remove();
                    $("#upload-status").modal('hide');
                    alert_modal("文件上传失败，请刷新后重试！");
                }
                else {
                    for (var i=0;i<response.new_upload_id.length;++i) {
                        var uploadFilehtml;
                        if(response.is_on_time == "NO") {
                            uploadFilehtml = ''
                                + '<div id="my-submit' + response.new_upload_id[i] + '" class="alert alert-danger alert-dismissable" role="alert" data-upload-name="'
                                + response.new_upload_name[i] + '" data-upload-id="' + response.new_upload_id[i] + '">'
                                + '<button type="button" class="close" aria-label="Close">'
                                + '<span class="delete-upload" aria-hidden="true" onclick="delete_upload(this);">&times;</span></button>'
                                + '<i class="es-icon es-icon-description status-icon pull-left"></i>'
                                + '<a href="/static/homework/upload/' + response.new_upload_uri[i] + '" download="'
                                + response.new_upload_name[i] + '" class="col-md-8 col-sm-8">' + response.new_upload_name[i] + '</a>'
                                + '<span>提交于：' + response.new_upload_submit_time[i]  + '</span>'
                                + '</div>';
                        }
                        else {
                            uploadFilehtml = ''
                                + '<div id="my-submit' + response.new_upload_id[i] + '" class="alert alert-success alert-dismissable" role="alert" data-upload-name="'
                                + response.new_upload_name[i] + '" data-upload-id="' + response.new_upload_id[i] + '">'
                                + '<button type="button" class="close" aria-label="Close">'
                                + '<span class="delete-upload" aria-hidden="true" onclick="delete_upload(this);">&times;</span></button>'
                                + '<i class="es-icon es-icon-description status-icon pull-left"></i>'
                                + '<a href="/static/homework/upload/' + response.new_upload_uri[i] + '" download="'
                                + response.new_upload_name[i] + '" class="col-md-8 col-sm-8">' + response.new_upload_name[i] + '</a>'
                                + '<span>提交于：' + response.new_upload_submit_time[i]  + '</span>'
                                + '</div>';
                        }
                        $("#my-uploads").append(uploadFilehtml);
                    }
                    myDropzone.removeAllFiles();
                    $("#upload-status .dz-complete").remove();
                    $("#upload-status").modal('hide');
                }
            });
            $("#upload-status #dialog-mini-btn").click(function () {
                $("#upload-status .modal-body").toggle();
            });
            $("#dialog-close-btn").click(function () {
                myDropzone.removeAllFiles();
                $("#upload-status .dz-complete").remove();
                $("#upload-status").modal('hide');
            });
        },
        headers: {
            'X-CSRFToken': csrf_token
        }
    });
});