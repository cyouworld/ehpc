
//为所有题目添加本试卷中的题号：q1、q2、q3...
var question_index = 1;
$('#question-single-choice').find("span[data-id=num-id]").each(function () {
    $(this).text(question_index);
    $(this).parent().parent().parent().attr('id', 'q' + question_index.toString());
    question_index++;
});
$('#question-multiple-choice').find("span[data-id=num-id]").each(function () {
    $(this).text(question_index);
    $(this).parent().parent().parent().attr('id', 'q' + question_index.toString());
    question_index++;
});
$('#question-uncertain-choice').find("span[data-id=num-id]").each(function () {
    $(this).text(question_index);
    $(this).parent().parent().parent().attr('id', 'q' + question_index.toString());
    question_index++;
});
$('#question-fill').find("span[data-id=num-id]").each(function () {
    $(this).text(question_index);
    $(this).parent().parent().parent().attr('id', 'q' + question_index.toString());
    question_index++;
});
$('#question-judge').find("span[data-id=num-id]").each(function () {
    $(this).text(question_index);
    $(this).parent().parent().parent().attr('id', 'q' + question_index.toString());
    question_index++;
});
$('#question-essay').find("span[data-id=num-id]").each(function () {
    $(this).text(question_index);
    $(this).parent().parent().parent().attr('id', 'q' + question_index.toString());
    question_index++;
});

//根据填空题答案长度生成对应长度的填空框
$("span[data-id=fill-id]").each(function () {
    var solution_len = $(this).data('len').split(';');
    var i = 0;
    $(".fill-input").each(function () {
        $(this).css('width', ((solution_len[i].length) * 100 + 40).toString() + 'px');
        i++;
    });
});

//初始化问答题答题框
var essay = {};
$('#question-essay').find('textarea[data-id=target-editor]').each(function () {
    var obj = this;
    essay[$(this).parent().parent().data('id')] = custom_simplemde({
        element: obj,
        autosave: true,
        showIcons: ["code", "table"],
        tabSize: 4,
        spellChecker: false,
        status: ["lines", "words", "cursor",
            {onUpdate: function (e1) {//添加更新事件，每当框中内容有所变化时触发
                var temp = $(obj).parent().parent().find('span[data-id=num-id]').text();
                if (essay[$(obj).parent().parent().data('id')].value() != ""){//根据答题框内是否有内容来判断该题是否已答，进而更新右侧答题卡状态
                    $('#paper-card').find('a[data-id=' + temp + ']').addClass('active');
                }
                else{
                    $('#paper-card').find('a[data-id=' + temp + ']').removeClass('active');
                }
            }}]
    });
});


$(document).ready(function () {
    $('#paper-card').find('a').click(function () {//为右侧答题卡创建点击跳转至题目事件
        $("html,body").animate({scrollTop:$('#q'+$(this).data('id')).offset().top - 70}, 300);
    });

    $('#paper-nav').find('a').click(function () {//为顶部题型导航栏创建点击跳转至题目事件
        $("html,body").animate({scrollTop:$('#'+$(this).data('goto')).offset().top - 70}, 300);
    });

    $(window).scroll(function () {//滚动触发事件，用于实现【顶部题目类型选择栏】和【右侧答题卡】随页面一起滚动的效果
        if ($(window).scrollTop() > 200) {
            $('#paper-nav').addClass('paper-nav');
            $('#paper-nav').addClass('affix');
            $('#paper-card').addClass('paper-card');
        }
        else {
            $('#paper-nav').removeClass('paper-nav');
            $('#paper-nav').removeClass('affix');
            $('#paper-card').removeClass('paper-card');
        }
    });

    //更新顶部题目类型选择栏，提示用户当前选择的题型
    var nav_chosen = null;
    $('.nav-pills').find('li[data-id=nav]').click(function () {
        if (nav_chosen != null) {
            nav_chosen.removeClass('active');
        }
        nav_chosen = $(this);
        nav_chosen.addClass('active');
    });

    //根据用户当前页面所在位置的题目类型，更新顶部题目类型选择栏
    $(window).scroll(function () {
        var a = [$('#head-single'), $('#head-multiple'), $('#head-uncertain'), $('#head-fill'), $('#head-judge'), $('#head-essay'), $('#footer-paper')];
        var current;
        for(var i=0;i<6;i++){
            if($(window).scrollTop()+100>=a[i].offset().top && $(window).scrollTop()<a[i+1].offset().top-100){
                current = i;
                break;
            }
        }
        if (nav_chosen != null){
            nav_chosen.removeClass('active');
        }
        nav_chosen = $('.nav-pills').find('li[data-id=nav]').eq(i);
        nav_chosen.addClass('active');
    });

    //单选题选项逻辑实现
    $('#question-single-choice').find('ul[data-id=choice-options]').find('li').click(function () {
        var flag = false;//当前选项是否已被选择
        if($(this).data('check')=='1'){
            flag = true;
        }
        $(this).parent().children().each(function () {//重置所有选项状态为：未选择
            $(this).data('check', '0');
            $(this).find('i').hide();
        });

        //使用户可以取消【单选题】中已选择的一项
        if(flag){//若当前选项在重置前已选择，则更新为：未选择
            $(this).data('check', '0');
            $(this).find('i').hide();
        }
        else{//否则更新为：选中
            $(this).data('check', '1');
            $(this).find('i').show();
        }

        //判断是否有选项被选中
        flag = false;
        $(this).parent().children().each(function () {
            if($(this).data('check') == '1' ){
                flag = true;
            }
        });


        var temp = $(this).parent().parent().parent().find('span[data-id=num-id]').text();
        if(flag){//如果有选项被选中则，更新右侧答题卡状态为：已做
            $('#paper-card').find('a[data-id=' + temp + ']').addClass('active');
        }
        else{
            $('#paper-card').find('a[data-id=' + temp + ']').removeClass('active');
        }
    });

    //多选题，不定项选择选项逻辑相同，故放在一起
    $('#question-multiple-choice, #question-uncertain-choice').find('ul[data-id=choice-options]').find('li').click(function () {
        if ($(this).data('check') == '0') {//若该选项未选择则标记为选择
            $(this).data('check', '1');
            $(this).find('i').show();
        }
        else {//反之，标记为未选择
            $(this).data('check', '0');
            $(this).find('i').hide();
        }

        //判断是否有选项被选中
        var flag = false;
        $(this).parent().children().each(function () {
            if($(this).data('check') == '1' ){
                flag = true;
            }
        });

        var temp = $(this).parent().parent().parent().find('span[data-id=num-id], span[data-id=num-id]').text();
        if(flag){//如果有选项被选中则，更新右侧答题卡状态为：已做
            $('#paper-card').find('a[data-id=' + temp + ']').addClass('active');
        }
        else{
            $('#paper-card').find('a[data-id=' + temp + ']').removeClass('active');
        }

    });

    $('ul[data-id=judge-options]').find('li').click(function () {
        var flag = false;//当前选项是否已被选择
        if($(this).data('check')=='1'){
            flag = true;
        }

        $(this).parent().children().each(function () {//清空T、F选项选中状态
            $(this).data('check', '0');
            $(this).find('i').hide();
        });

        if(flag){//若重置前已选择，则标记为未选择
            $(this).data('check', '0');
            $(this).find('i').hide();
        }
        else{//反之，选择
            $(this).data('check', '1');
            $(this).find('i').show();
        }

        //判断是否有选项被选中
        flag = false;
        $(this).parent().children().each(function () {
            if($(this).data('check') == '1' ){
                flag = true;
            }
        });

        var temp = $(this).parent().parent().parent().find('span[data-id=num-id]').text();
        if(flag){//若是，则更新右侧答题卡状态为：已做
            $('#paper-card').find('a[data-id=' + temp + ']').addClass('active');
        }
        else{
            $('#paper-card').find('a[data-id=' + temp + ']').removeClass('active');
        }
    });

    $('.fill-input').keyup(function () {//为填空题添加按键响应
        var flag = false;
        $(this).parent().find('.fill-input').each(function () {
            if($(this).val() != ""){
                flag = true;
                return false;
            }
        });

        var temp = $(this).parent().parent().find('span[data-id=num-id]').text();
        if(flag){//若所有空内容有不为空的，则标记为已做
            $('#paper-card').find('a[data-id=' + temp + ']').addClass('active');
        }
        else{
            $('#paper-card').find('a[data-id=' + temp + ']').removeClass('active');
        }
    });



    $('#submit-solution').click(function () {//提交按钮点击事件
        var your_answer = {};//答案类，包含用户所有的回答
        //处理选择题
        $('#question-single-choice,#question-multiple-choice,#question-uncertain-choice').find('div[data-name=question]').each(function () {
            var question_id = $(this).data('id');//该选择题在数据库中的id
            var temp = [];
            $(this).find('ul[data-id=choice-options]').find('li').each(function () {
                if ($(this).data('check') == '1') {//找出被选中的选项
                    temp.push($(this).find('span[data-id=option]').text());
                }
            });
            if(temp.length!=0) your_answer[question_id.toString()] = temp.join(';');//以分号连接
            else your_answer[question_id.toString()] = "";
        });

        //处理填空题
        $('#question-fill').find('div[data-name=question]').each(function () {
            var question_id = $(this).data('id');
            var temp = [];
            $('.fill-input').each(function () {
                temp.push($(this).val());
            });

            if(temp.length!=0) your_answer[question_id.toString()] = temp.join(';');
            else your_answer[question_id.toString()] = "";
        });

        //处理判断题
        $('#question-judge').find('div[data-name=question]').each(function () {
            var question_id = $(this).data('id');
            var temp = "";
            $(this).find('ul[data-id=judge-options]').find('li').each(function () {
                if ($(this).data('check') == '1') {
                    temp = $(this).find('span[data-id=option]').text();
                }
            });
            if (temp == 'T') your_answer[question_id.toString()] = '1';
            else if(temp == 'F') your_answer[question_id.toString()] = '0';
            else your_answer[question_id.toString()] = '-1';
        });

        //处理问答题
        $('#question-essay').find('div[data-name=question]').each(function () {
            var question_id = $(this).data('id');
            your_answer[question_id.toString()] = essay[question_id].value();
        });

        //提交部分逻辑
        $.ajax({
            url: post_to,
            type: "post",
            dataType: "json",
            data: your_answer,
            success: function (data) {
                if (data['status'] == 'success') {//若状态为成功
                    page_end_time = moment();
                    $.ajax({
                        url: statistic_address,
                        type: "post",
                        data: {
                            paper_id: paper_id,
                            course_id: course_id,
                            result: JSON.stringify(data['result']),
                            start_time: page_start_time.format("YYYY-MM-DD HH:mm:ss"),
                            end_time: page_end_time.format("YYYY-MM-DD HH:mm:ss"),
                            action_code: "20003"
                        }
                    });

                    var count=0;
                    //取出每种题型回答正确的题目数量
                    $('#result').find('.text-success').find('small').each(function () {
                        $(this).text(data['correct_num'][count.toString()]);
                        count++;
                    });

                    for (var i=0;i<6;i++){
                        wrong_num[i] -= data['correct_num'][i.toString()];
                    }

                    count = 0;
                    $('#result').find('.text-danger').find('small').each(function () {
                        $(this).text(wrong_num[count]);
                        count++;
                    });

                    //每种题型得到的分数
                    var points = [0, 0, 0, 0, 0, 0];
                    for(var t in data['result']){
                        if (data['result'][t]=="T") {//若答对
                            var point = $('div[data-name=question][data-id=' + t.toString() + ']').eq(0).data('point');//取出该题分数
                            point = Number(point);//转换类型
                            points[Number($('div[data-name=question][data-id=' + t.toString() + ']').eq(0).data('type'))] += point;//计入该题对应题型所获得的分数
                            $('div[data-name=question][data-id=' + t.toString() + ']').find('img[data-id=choice_correct]').show();//显示答对图标
                        }
                        else{
                            $('div[data-name=question][data-id=' + t.toString() + ']').find('img[data-id=choice_wrong]').show();//显示答错图标
                        }
                    }

                    //在顶部结果栏中显示每种题型获得的分数
                    count = 0;
                    $('#result').find('.text-score').find('small').each(function () {
                        $(this).text(points[count].toString());
                        count++;
                    });

                    $('#result').show();

                    //每道题显示正确答案
                    for(var k in data['solution']){
                        var sol = $('div[data-id=' + k + ']').find('strong[data-id=correct-sol]').eq(0);
                        sol.css('color','#70d445');
                        sol.text(data['solution'][k]);
                        sol.parent().parent().show();
                    }
                    $('#submit-solution').addClass('disabled');//提交按钮不可点击
                    $('#submit-solution').hide();//隐藏提交按钮

                    $("html,body").animate({scrollTop:0}, 300);//回到试卷顶部查看结果
                }
                else {
                    alert_modal("失败");
                }
            }
        })

    });

});