$(function () {
   var Accordion = function (el, multiple) {
        this.el = el || {};
        this.multiple = multiple || false;
        // Variables privadas
        var links = this.el.find('.link');
        // Evento
        links.on('click', {el: this.el, multiple: this.multiple}, this.dropdown)
    };
    Accordion.prototype.dropdown = function () {
        $this = $(this);
        $next = $this.next();
        $next.slideToggle();
    };
    var accordion_html = $('#accordion');
    var accordion = new Accordion(accordion_html, false);

    // accordion_html.find('a').click(function () {
    //     $('.link').parent().removeClass('open');
    //     accordion_html.find('a').removeClass('active');
    //     $(this).addClass('active');
    //     $('span[data-id=case-name]').css('color', '#616161');
    //     $('i[data-id=case-icon]').css('color', "#616161").css('-webkit-transform', "initial")
    //         .css('-ms-transform', "initial").css('-o-transform', "initial").css('transform', "initial");
    //     $('i[data-id=case-icon2]').css('color', "#616161");
    // });
});
