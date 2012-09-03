(function($) {
  $.fn.extend({
    setupHorizontalScroll : function() {
      var lis = $(this).children('li');
      var leftVal = 0;
      lis.each(function( index, obj) {
        leftVal = 120 * index;
        $(obj).css({
          left: leftVal
        });
      });
    
    },
  });
  
})(jQuery);