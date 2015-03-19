
$(document).ready(function() {
   $('pre.r').next().each(function(index) {
      if($(this).is("pre") & $(this).attr("class") == undefined) {
        $(this).addClass("r-output");
        $(this).addClass("nohighlight");
      }
   });
});

