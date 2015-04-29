
$(document).ready(function() {
   $('pre.r').next().each(function(index) {
      if($(this).is("pre") & $(this).attr("class") == undefined) {
        $(this).addClass("r-output");
        $(this).addClass("nohighlight");
      }
   });
});

function handleSticky() {
  if($(window).width() > 979) {
    var stickBottom = true;
    if($(window).height() > $("#sidebar-col").height())
      stickBottom = false;
    $("#sidebar-col").stick_in_parent({offset_top: 60, bottoming: stickBottom});
  } else {
    $("#sidebar-col").trigger("sticky_kit:detach");
  }
}

$(document).ready(function() {
  $('#toc ul:first').addClass('nav nav-stacked');
  $('#toc ul:first').attr('id', 'sidebar');

  // add class to toc sub-elements
  $('#toc ul:first ul').addClass("nav nav-stacked")

  handleSticky();

  $('tr.header').parent('thead').parent('table').addClass('table table-condensed');

  var $body    = $(document.body);
  var navHeight = $('.navbar').outerHeight(true) + 40;

  $body.scrollspy({
    target: '#toc',
    offset: navHeight
  });

  $('body').scrollspy('refresh');

  hljs.initHighlightingOnLoad();
});

// jQuery for page scrolling feature - requires jQuery Easing plugin
$(function() {
  $('#sidebar li a, .page-scroll').bind('click', function(event) {
    var $anchor = $(this);
    $('html, body').stop().animate({
        scrollTop: $($anchor.attr('href')).offset().top - 80
    }, 500, 'easeInOutExpo');
    event.preventDefault();
  });
});

// let a user resize for 250ms before triggering actions
$(window).resize(function() {
   if(this.resizeTO) clearTimeout(this.resizeTO);
   this.resizeTO = setTimeout(function() {
      $(this).trigger('resizeEnd');
   }, 250);
});

$(window).bind('resizeEnd', function() {
  handleSticky();
});
