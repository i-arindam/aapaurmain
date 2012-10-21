$(function () {
  var inPane = new ViewerPaneController('in_pane');
  var outPane = new ViewerPaneController('out_pane');
  var recoPane = new ViewerPaneController('recos_pane');
  var profViewPane = new ViewerPaneController('prof_view_pane');
  inPane.bindNewAdditions();
  outPane.bindNewAdditions();
  recoPane.bindNewAdditions();
  profViewPane.bindNewAdditions();
  
  $('.incomingRequests').setupHorizontalScroll();
  $('.outgoingRequests').setupHorizontalScroll();
  $('.recommendations').setupHorizontalScroll();
  
  $('.mainNav li').click(function(e) {
    if($(this).hasClass('active')) {
      return false;
    }
    e.preventDefault();
    $('.mainNav li.active').removeClass('active');
    $(this).addClass('active');

    var index = $('.mainNav li').index(this);
    $('.requestContainer').not('.hide').addClass('hide');
    $('.requestContainer:eq(' + index + ')').removeClass('hide');
    $('.viewerPane').not('hide').addClass('hide');
    $('.viewerPane:eq(' + index + ')').removeClass('hide');
  });
  
});

