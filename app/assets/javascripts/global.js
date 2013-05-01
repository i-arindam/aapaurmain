(function($) {
  $('.close').click(function(e) {
    e.preventDefault();
    $(this).parent().toggle('slow');
  });

})(jQuery);
