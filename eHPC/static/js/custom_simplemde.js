//editor: 编辑框本身
//e: event类型，事件本身
//url: 提交到的视图函数url
//提交时，img为图片文件的key，键op表示操作为上传图片
//上传成功后，后台会返回图片地址（例如：static/case/1.png）
//该地址将按照markdown图片格式自动插入到光标处
document.write('<script type="text/javascript" src="/static/js/markdown_latex_support.js"></script>');
document.write('<script type="text/javascript" src="/static/js/colorpicker/bootstrap-colorpicker.min.js"></script>');

function custom_simplemde() {
    if (arguments[0]) {
        var flag = false;
        for (var k in arguments[0]) {
            if (k == "previewRender") {
                flag = true;
                break;
            }
        }
        if (!flag) {
            arguments[0].previewRender = latex_support;
        }
    }

    var simplemde;
    if(arguments[0]){
        var options = arguments[0];
        options['toolbar'] = [
            "bold",
            "italic",
            "heading",
            "|",
            "code",
            "quote",
            "unordered-list",
            "ordered-list",
            "|",
            "link",
            "image",
            "table",
            "|",
            "preview",
            "side-by-side",
            "fullscreen",
            "|",
            {
                name: "color",
                className: "fa fa-pencil",
                title: "Color"
            },
            "guide"
        ];
        simplemde = new SimpleMDE(options);
    }
    else{
        simplemde = new SimpleMDE({
            element: document.getElementById("target-editor"),
            autosave: true,
            showIcons: ["code", "table"],
            tabSize: 4,
            spellChecker: false,
            previewRender: latex_support,
            toolbar: [
                "bold",
                "italic",
                "heading",
                "|",
                "code",
                "quote",
                "unordered-list",
                "ordered-list",
                "|",
                "link",
                "image",
                "table",
                "|",
                "preview",
                "side-by-side",
                "fullscreen",
                "|",
                {
                    name: "color",
                    className: "fa fa-pencil",
                    title: "Color"
                },
                "guide"
            ]
        });
    }

    var font_color_icon = $("a[title=Color].fa.fa-pencil");

    font_color_icon.colorpicker({
        colorSelectors: {
            'black': '#000000',
            'white': '#ffffff',
            'red': '#FF0000',
            'default': '#777777',
            'primary': '#337ab7',
            'success': '#5cb85c',
            'info': '#5bc0de',
            'warning': '#f0ad4e',
            'danger': '#d9534f'
        }
    });

    var color = null, position_start, position_end, selection;
    font_color_icon.on('showPicker', function (e) {
        position_start = simplemde.codemirror.listSelections()[0].head;
        position_end = simplemde.codemirror.listSelections()[0].anchor;
        selection = simplemde.codemirror.getSelection();
    });
    font_color_icon.on('changeColor', function(e){
        if(e.color!==null) {
            color = e.color.toString('rgba');
        }
    });
    font_color_icon.on('hidePicker', function (e) {
        simplemde.codemirror.setSelection(position_end, position_start);
        if(color === null) return;
        if (simplemde.codemirror.getSelection().length === 0){
            simplemde.codemirror.replaceSelection('<span style="color: ' + color + ';"></span>');
            simplemde.codemirror.setCursor(simplemde.codemirror.listSelections()[0].anchor.line, simplemde.codemirror.listSelections()[0].anchor.ch - 7);
            return;
        }
        simplemde.codemirror.replaceSelection('<span style="color: ' + color + ';">' + selection + '</span>');
        color = null;
    });

    var is_loading = false;

    simplemde.codemirror.on('drop', function (editor, e) {
        if (is_loading) {
            alert_modal("请等待当前上传的完成！");
            return;
        }
        is_loading = true;
        var fileList = e.dataTransfer.files;
        if (fileList.length > 1) {
            alert_modal('一次只能上传一张图片');
            is_loading = false;
            return false;
        }
        if (fileList[0].type.indexOf('image') === -1) {
            alert_modal("不是图片！");
            is_loading = false;
            return false;
        }
        var img = new FormData();
        img.append('img', fileList[0]);
        var pos = {line: editor.getCursor().line, ch: editor.getCursor().ch};
        $("#progress-percent").show();
        $("#progress-text").show();
        $(".progress").slideDown();

        var count = 0;
        $.ajax({
            type: "post",
            url: $(simplemde.element).data('img-upload-url'),
            data: img,
            processData: false,
            contentType: false,

            xhr: function () {
                myXhr = $.ajaxSettings.xhr();
                if (myXhr.upload) {
                    myXhr.upload.addEventListener('progress', function (e) {
                        $(".progress-bar").css("width", (e.loaded / e.total * 100).toString() + "%");
                        $("#progress-percent").text(Math.round(e.loaded / e.total * 100).toString() + " %");
                    }, false);
                }
                return myXhr;
            },

            success: function (data) {
                if (data["status"] == "success") {
                    editor.replaceRange("![](" + data['uri'] + ")", pos);
                }
                else {
                    alert_modal("上传图片失败");
                }
                $("#progress-percent").hide();
                $("#progress-text").hide();
                $(".progress").slideUp();
                $(".progress-bar").css("width", "0%");
                $("#progress-percent").text("0 %");

                is_loading = false;
            }
        });
    });
    return simplemde;
}

