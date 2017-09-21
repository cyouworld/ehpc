var import_mathjax = '<script type="text/x-mathjax-config">\
                      MathJax.Hub.Config({\
                          skipStartupTypeset: true\
                      })\
                      </script>\
                      <script type="text/javascript" src="https://cdn.bootcss.com/mathjax/2.7.0/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>';
//使用document.write时，请在script标签中加入async属性，否则可能导致页面渲染时不响应

document.write(import_mathjax);
function latex_support(plainText) {
    plainText = plainText.toString();
    $(".lab-content-wrap, .content-wrap").append("<div id='latex-render-area' style='display: none'></div>");
    var temp = plainText.match(/\\\([\s\S]*?\\\)|\\\[[\s\S]*?\\\]/g);
    if(temp!=null){
        for(var i=0;i<temp.length;i++){
            $("#latex-render-area").append("<span id='sp-rep-latex-" + (i+1).toString() + "'>" + temp[i] + "</span>");
        }
        var count = 0;
        MathJax.Hub.Queue(["Typeset", MathJax.Hub, 'latex-render-area']);
        count = 0;
        plainText = plainText.replace(/\\\([\s\S]*?\\\)|\\\[[\s\S]*?\\\]/g, function (word) {
            count++;
            return "sp-rep-latex-" + count.toString();
        });
        plainText = SimpleMDE.prototype.markdown(plainText);
        count = 0;
        plainText = plainText.replace(/sp-rep-latex-\d*/g, function (word) {
            count++;
            return $("#sp-rep-latex-" + count.toString()).html();
        });
        MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
        $("#latex-render-area").remove();
    }
    else{
        plainText = SimpleMDE.prototype.markdown(plainText);
    }
    return plainText;
}



