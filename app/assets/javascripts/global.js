$(document).ready(function() {
  $('a.close').on('click', function(e) {
    e.preventDefault();
    $(this).parent().toggle('slow');
  });
  $('a[rel=tooltip]').tooltip();

  $('img.img-thumb, img.img-dp').livequery('click', function(e) {
    e.preventDefault();
    var src = this.src;
    if (src.indexOf("-thumb") !== -1 || src.indexOf("-dp") !== -1) {
      var toRemove = src.match(/.*profile\-\d+((-thumb|-dp)\?\d+)/)[1];
    } else if(src.indexOf("-150") !== -1) {
      var toRemove = "-150";
    }
    src = src.replace(toRemove, "");
    $('div.image-displayer').remove();
    $('<div/>').addClass('image-displayer modal').appendTo($('body'));
    $('<a/>').addClass('close').text('x').appendTo($('div.image-displayer'));
    $('<img/>').addClass('full-image').attr('src', src).appendTo($('div.image-displayer'));
    $('div.image-displayer').modal('show');
    $('img.full-image').unbind('load').load(function() {
      var picDisplayer = $('div.image-displayer');
      var imgWidth = this.width, imgHeight = this.height;
      var paddingLeft = parseInt(picDisplayer.css('padding-left'), 10), paddingRight = parseInt(picDisplayer.css('padding-right'), 10);
      var paddingTop = parseInt(picDisplayer.css('padding-top'), 10), paddingBot = parseInt(picDisplayer.css('padding-bottom'), 10);
      var leftVal = ( $(window).width() - imgWidth - paddingLeft - paddingRight) / 2;
      var topVal = ( $(window).height() - imgHeight - paddingTop - paddingBot) / 2;
      picDisplayer.css({
        top: topVal,
        left: leftVal,
        margin: 0
      });
    });
  });
  $('.modal.image-displayer a.close').livequery('click', function(e) {
    e.preventDefault();
    $('div.image-displayer').modal('hide');
  });
});
