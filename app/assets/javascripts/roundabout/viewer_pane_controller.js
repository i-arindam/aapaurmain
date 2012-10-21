function ViewerPaneController(id){
  this.selector = '#' + id;
  this._init();
}

ViewerPaneController.prototype._init = function(){
  this.container = $(this.selector);
  this.liSelectorClass = ".select-thumbnails";
  this.viewerPane = this.container.roundabout({'startWidth' : 400 , 'startHeight' : 320});
};

ViewerPaneController.prototype.skipTo = function(index){
 this.container.roundabout("animateToChild", index);
};

ViewerPaneController.prototype.addChild = function(childElement,index){
  this.container.append(childElement);
  this.container.roundabout("relayoutChildren");
  var index = $(this.selector+ ' li:last').index();
  this.skipTo(index);
};

/*
  Returns the index of the child if present in viewer pane
*/
ViewerPaneController.prototype.hasChild = function(childSelector){
  return $('li', this.selector).index($(childSelector));

}


ViewerPaneController.prototype.bindNewAdditions = function() {
  var that = this;
  $(that.liSelectorClass).live('click',function(evt){
    evt.preventDefault();
    var index = that.hasChild('#' + 'user_' + this.id);
    
     that.skipTo(index);
   
 });
  
}