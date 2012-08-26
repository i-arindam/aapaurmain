function ViewerPaneController(config){
  defaultconfig = {
    'selector' : 'ul'
  }
  this.config = config || defaultConfig ;
  this._init();
}

ViewerPaneController.prototype._init = function(){
  this.container = $(this.config.selector);
  this.viewerPane = this.container.roundabout({'startWidth' : 400 , 'startHeight' : 320});
};

ViewerPaneController.prototype.skipTo = function(index){
 this.container.roundabout("animateToChild", index);
};

ViewerPaneController.prototype.addChild = function(childElement,index){
  this.container.append(childElement);
  this.container.roundabout("relayoutChildren");
  var index = $(this.config.selector+ ' li:last').index();
  this.skipTo(index);
};

/*
  Returns the index of the child if present in viewer pane
*/
ViewerPaneController.prototype.hasChild = function(childSelector){
  return $('li', this.config.selector).index($(childSelector));

}


