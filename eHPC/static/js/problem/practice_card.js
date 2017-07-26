
var number=1;//当前答题题号
var corNum = {} ,ifHasDone = {};//题目是否回答正确，题目是否已答

$(function () {
    var question_index = $('#question-index');
    var selectpicker = $('.selectpicker');
    var next_problem = $('#nextProblem');
    var last_problem = $('#lastProblem');

    selectpicker.change(function () {
        var select_practice = $('.selectpicker').selectpicker('val').split('-');
        var begin = Number(select_practice[0]), end = Number(select_practice[1]);
        question_index.find('a').hide();
        for(var i=begin;i<=end;i++){
            $('#question-index').find('a[data-id=' + i.toString() + ']').show();
        }
    });
    selectpicker.trigger('change');

    for (i=0;i<practice_count;i++)
    {
        corNum[(i+1).toString()] = false;
        ifHasDone[(i+1).toString()] =false;
    }

//下一题按钮点击事件
    next_problem.click(function () {
        if(number==practice_count) return;//若当前题目已是最后一题，则退出函数
        number++;//切换下一题
        last_problem.removeClass('disabled');//上一题按钮设置为可点
        $('div[data-id=' + (number-1).toString() + ']').hide();
        $('div[data-id=' + number.toString() + ']').show();
        if(number==practice_count) $(this).addClass("disabled");//若已是最后一题，则自身标记为不可点

        if(number % 8 == 1){
            var temp = (number - 1) / 8;
            selectpicker.selectpicker('val', selectpicker.find('option').eq(temp).val());
            selectpicker.trigger('change');
        }
    });

//上一题按钮点击事件
    last_problem.click(function () {
        if(number==1) return;
        number--;
        next_problem.removeClass('disabled');
        $('div[data-id=' + (number+1).toString() + ']').hide();
        $('div[data-id=' + number.toString() + ']').show();
        if(number==1) $(this).addClass("disabled");

        if(number % 8 == 0){
            var temp = number / 8;
            selectpicker.selectpicker('val', selectpicker.find('option').eq(temp-1).val());
            selectpicker.trigger('change');
        }
    });

//显示答案
    $('#show-solution').click(function () {
        $('div[data-id=' + number.toString() + ']').find('div[data-id=solution]').toggle();
    });

    $('#pause').click(function () {//暂停按钮
        clearInterval(clock);//停止更新时间
        ifClock = false;
        $("#pauseModal").modal({backdrop: 'static', keyboard: false});//显示暂停模态框
    });

    $('#continue').click(function () {//继续按钮
        if(ifClock==false)
        {
            $("#pauseModal").modal("hide");//隐藏暂停模态框
            clock = setInterval("updateClock(second)", 100);//继续计时
            ifClock = true;
        }
    });

    $('#confirm-submit').click(function () {
        page_end_time = moment();
        var status = {};
        for(var k in corNum){
            status[$('div[class=panel][data-id=' + k + ']').eq(0).data('q-id')] = corNum[k];
        }
        $.ajax({
            url: statistic_address,
            type: "post",
            data: {
                status: JSON.stringify(status),
                classify_id: classify_id,
                start_time: page_start_time.format("YYYY-MM-DD HH:mm:ss"),
                end_time: page_end_time.format("YYYY-MM-DD HH:mm:ss"),
                action_code: "30002"
            },
            success: function (data) {
                if(data["status"] === "success"){
                    window.location.href=address;
                } else{
                    alert_modal("提交失败请重试！");
                }
            }
        })
    });

    $('#cancel-submit').click(function () {
        if(ifClock == false){
            clock = setInterval("updateClock(second)", 100);
            ifClock = true;
        }
        $("#submitModal").modal('hide');
    });

    question_index.find('a').click(function () {
        var temp = $(this).data('id');
        $('div[data-id=' + number.toString() + '][class=panel]').hide();
        number = Number(temp);
        $('div[data-id=' + number.toString() + '][class=panel]').show();
        last_problem.removeClass('disabled');
        next_problem.removeClass('disabled');
        if(number == 1){
            last_problem.addClass('disabled');
        }
        else if(number == practice_count){
            next_problem.addClass('disabled');
        }
    });
});
