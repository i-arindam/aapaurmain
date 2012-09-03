$(function () {
  var pane = new ViewerPaneController();
  pane.bindNewAdditions();
  
  $('.searchList').setupHorizontalScroll();
});
