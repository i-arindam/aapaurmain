(function($) {
  $('.close').click(function(e) {
    e.preventDefault();
    $(this).parent().toggle('slow');
  });

  $.fn.extend({
    setupHorizontalScroll : function() {
      var lis = $(this).children('li');
      var extra_elements = lis.length - 5; //we show upto 5 elements with the current width
      if(extra_elements > 0) {
        var currentWidth = $(this).width();
        $(this).css({width: currentWidth+(120*extra_elements)});
      }

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
