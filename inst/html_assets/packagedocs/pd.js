$(document).ready(function() {
  // highlighting
  $('pre.r').next().each(function(index) {
    if($(this).is("pre") & $(this).attr("class") == undefined) {
      $(this).addClass("r-output");
      $(this).addClass("nohighlight");
    }
  });

  // add class to toc elements
  $('#toc ul:first').addClass('nav nav-stacked');
  $('#toc ul:first').attr('id', 'sidebar');

  // add class to toc sub-elements
  $('#toc ul:first ul').addClass("nav nav-stacked")

  // table styling
  $('tr.header').parent('thead').parent('table').addClass('table table-condensed');

  var $body     = $(document.body);
  var navHeight = $('.navbar').outerHeight(true) + 40;

  $body.scrollspy({
    target: '#toc',
    offset: navHeight
  });

  hljs.initHighlightingOnLoad();
});


