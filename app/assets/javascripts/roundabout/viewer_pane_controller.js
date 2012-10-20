function ViewerPaneController(){
  this.selector = '.user-container';
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
    if (index === -1){
    $.ajax({
       type: "GET",
       url: '/users/' + this.id + '/more_info',
       dataType: "html",
       success: function(html_data){
         that.addChild(html_data);
       },
       failure: function(){
        console.log("FUcked");
       }

     });
   }else{
     that.skipTo(index);
   }
 });
  
}
