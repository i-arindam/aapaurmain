(function($) {
  $('.close').click(function(e) {
    e.preventDefault();
    $(this).parent().toggle('slow');
  });

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
    }
  }); // $.fn.extend
  
  var dropdownSelector = 'ul.dropdown-menu:not(.dontToggle) li a';
  
  $.extend({
    setupDropdownDisplays : function() {
      $(dropdownSelector).click(function(e) {
        e.preventDefault();
        $(this).closest('div.btn-group').children('input').attr('value', $(this).attr('data-value'));
      });
    },
    setupDropdownInputs : function() {
      $(dropdownSelector).click(function(e) {
        e.preventDefault();
        $(this).parents('ul').siblings('a').text($(this).text());
      });
    }
  }); // $.extend

})(jQuery);
