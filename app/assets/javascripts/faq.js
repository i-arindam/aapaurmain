$(document).ready(function() {
  $('#faq-wrapper li').click(function(e) {
    if($(this).hasClass('active')) {
      return false;
    }
    e.preventDefault();
    $('#faq-wrapper li.active').removeClass('active');
    $(this).addClass('active');

    var index = $('#faq-wrapper li').index(this);
    $('.demo').not('.hide').addClass('hide');
    $('.demo:eq(' + index + ')').removeClass('hide');
   // $('.demo:eq(' + index + ')').toggler({ initShow: "div.collapse:eq(0)"});
    
    // var selector = '.demo:eq(' + index + ')';
    // $(selector).expandAll({
    //   trigger: "div.expand", 
    //   ref: "div.expand", 
    //   showMethod: "slideDown", 
    //   hideMethod: "slideUp", 
    //   oneSwitch : false
    // });
    
  });
  
  // $("#demo2 div.expand").toggler({initShow: "div.collapse:eq(0)"});
 
  // $("#demo2").expandAll({
  //   trigger: "div.expand", 
  //   ref: "div.expand", 
  //   showMethod: "slideDown", 
  //   hideMethod: "slideUp", 
  //   oneSwitch : false
  // });
});
