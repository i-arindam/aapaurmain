$(function () {
  if ($('.viewerPane').length) {
    var pane = new ViewerPaneController('noId');
    pane.bindNewAdditions();
  }
  
  $('.searchList').setupHorizontalScroll();
  
  $.setupDropdownDisplays();
  $.setupDropdownInputs();
});
