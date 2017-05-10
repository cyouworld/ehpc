$(document).ready(function () {
    var p_instance = $('#course-material-form').parsley();
    $("#material-table-body").find("input").prop("checked", false);

    $("#all-select").click(function () {
        var obj = this;
        $("#material-table-body").find("input").prop("checked", $(obj).prop("checked"));
    });

    $("#add-link-file").click(function () {
        $("#file-name-field").val("");
        $("#course-link-field").val("");
        $("#course-type-field1").prop("checked", false);
        $("#course-type-field2").prop("checked", false);
        p_instance.reset();
    });

    $("#upload-material-btn").click(function () {
        p_instance.validate();
        if (p_instance.isValid()) {
            $.ajax({
                url: location.href,
                type: "post",
                data: new FormData($('#course-material-form')[0]),
                cache: false,
                contentType: false,
                processData: false,
                success: function (data) {
                    if (data.status == "success") {
                        location.reload();
                    }
                    else {
                        alert_modal("上传失败 \n" + data['info']);
                    }
                },
                error: function (data) {
                    alert_modal("上传失败" + data['info']);
                }
            });
        }
    });

    $("#del-confirm").click(function () {
        var array = [];
        $("#material-table-body").find("input").each(function () {
            if ($(this).prop("checked")) {
                $(this).parent().parent().remove();
                array.push($(this).parent().parent().data("material_id"));
            }
        });

        $.ajax({
            type: "post",
            url: location.href,
            data: {
                op: "del",
                material_id: array
            },
            success: function (data) {
                if(data.status=="success"){
                    $("#file-manage-panel").find("input").prop("checked", false);
                    $("#del-warning").modal("hide");
                }
                else{
                    alert_modal("删除失败");
                }
            }
        });
    });

    $("#del-material-btn").click(function () {
        $("#del-warning").modal("show");
    });

    // Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
    var template = $("#template").parent().html();
    $("#template").remove();
    var error = false;
    $("#dropz").dropzone({
        url: location.href,
        maxFiles: 10,
        maxFilesize: 500,
        acceptedFiles: ".mp3,.mp4,.mkv,.pdf",
        autoProcessQueue: true,
        previewTemplate: template,
        previewsContainer: "#previews", // Define the container to display the previews
        clickable: ".fileinput-button", // Define the element that should be used as click trigger to select files.
        dictInvalidFileType: "不支持的文件类型",
        dictMaxFilesExceeded: "文件数量不能超过10个",
        dictFileTooBig: "文件大小不能超过512",
        init: function() {
            this.on("addedfile", function(file) {
                $("#upload-status").show();
            });
            this.on("error", function (file) {
               error = true;
                alert_modal("上传失败");
            });
            this.on("queuecomplete", function(file) {
                if (!error) {
                    location.reload();
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

});
