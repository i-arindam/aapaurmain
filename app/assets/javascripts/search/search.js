$(function () {
  var pane = new ViewerPaneController('noId');
  pane.bindNewAdditions();
  
  $('.searchList').setupHorizontalScroll();
  
  $.setupDropdownDisplays();
  $.setupDropdownInputs();
});
