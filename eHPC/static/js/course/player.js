/**
 * Created by feizhao on 16/11/24.
 */
$(function () {
    var video_player = '<div id="player" style="height:90%"></div>';
    var pdf_player = '<iframe id="player" class="course-player" frameborder="0" style="overflow:hidden;height:90%;width:100%" allowfullscreen></iframe>';
    var clappr = null;
    if (js_material_type == "pdf") {
        $("#player-content").empty().append(pdf_player);
        $("#player").attr("src", js_pdf_src);
    }
    else {
        $("#player-content").empty().append(video_player);
        clappr = new Clappr.Player({
            source: js_material_src,
            parentId: "#player",
            height: "100%",
            width: "100%",
            mediacontrol: {
                seekbar: "#46c37b",
                buttons: "#ffffff"
            }
        });
    }
    var Accordion = function (el, multiple) {
        this.el = el || {};
        this.multiple = multiple || false;
        // Variables privadas
        var links = this.el.find('.link');
        // Evento
        links.on('click', {el: this.el, multiple: this.multiple}, this.dropdown)
    };
    Accordion.prototype.dropdown = function (e) {
        var $el = e.data.el;
        $this = $(this);
        $next = $this.next();
        $next.slideToggle();
    };
    var accordion = new Accordion($('#accordion'), false);
    $(js_material_selector).parent().parent().addClass('open');
    $(js_material_selector).children('a').addClass('active');
    $('#accordion').find('a').click(function (evt) {
        evt.preventDefault();
        var obj = this;
        $.ajax({
            type: "post",
            url: js_ajax_url,
            data: {
                op: "type",
                id: $(obj).parent().attr('id').substr(8)
            },
            success: function (data) {
                page_end_time = moment();
                $.ajax({
                    url: statistic_address,
                    type: "post",
                    async: false,
                    data: {
                        material_id: $('#accordion').find('a.active').eq(0).parent().attr('id').substr(8),
                        start_time: page_start_time.format("YYYY-MM-DD HH:mm:ss"),
                        end_time: page_end_time.format("YYYY-MM-DD HH:mm:ss"),
                        action_code: "20001"
                    },
                    success: function (data) {
                        page_start_time = moment();
                    }
                });

                if (data['status'] == 'fail')
                    return;
                if (clappr != null)
                    clappr.destroy();
                if (data['type'] == "pdf") {
                    $("#player-content").empty().append(pdf_player);
                    $("#player").attr("src", js_pdf_data + data['uri']);
                }
                else {
                    $("#player-content").empty().append(video_player);
                    clappr = new Clappr.Player({
                        source: js_material_src.split('/', 5).join('/') + '/' + data['uri'],
                        baseUrl: 'http://cdn.clappr.io/latest',
                        parentId: "#player",
                        height: "100%",
                        width: "100%",
                        mediacontrol: {
                            seekbar: "#46c37b",
                            buttons: "#ffffff"
                        }
                    });
                }
                $('.link').parent().removeClass('open');
                $(obj).parent().parent().parent().addClass('open');
                $('#accordion').find('a').removeClass('active');
                $(obj).addClass('active');
                var id = $(obj).parent().attr('id').substr(8);
                window.history.pushState(null, '', "/course/res/" + id + '/');
            }
        });
    });
});
