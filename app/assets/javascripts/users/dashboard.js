$(function () {
  var pane = new ViewerPaneController({'selector' : '.user-container'});
  pane.bindNewAdditions();
  
  $('.incomingRequests').setupHorizontalScroll();
  $('.outgoingRequests').setupHorizontalScroll();
  $('.recommendations').setupHorizontalScroll();
});
