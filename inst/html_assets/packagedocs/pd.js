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

  // make hrefs in Rd scrollable
  $(".section code a").each(function() {
    var obj = $(this);
    if(obj.attr('href').charAt(0) == "#")  {
      obj.addClass("page-scroll");
    }
  });

  // get rid of dots in Rd ids to work with bootstrap's dumb scrollspy
  $('.section.level1 .section.level2').each(function() {
    var obj = $(this);
    var id = obj.attr('id');
    if(id.indexOf('.') !== -1 || id.indexOf('-') !== -1) {
      var new_id = id.replace(/\./g, '_');
      new_id = new_id.replace(/\-/g, '_');
      obj.attr('id', new_id);
      var ahrefs = $('a[href$="' + id + '"]');
      ahrefs.attr('href', '#' + new_id);
      ahrefs.addClass("page-scroll");
    }
  });

  $('body').scrollspy('refresh');
});

$(window).load(function() {
  // if there is a hash on page load, scroll to it
  if(window.location.hash.length > 0) {
    $('html, body').stop().animate({
        scrollTop: $(window.location.hash).offset().top - 80
    }, 100, 'easeInOutExpo');
  }
});

