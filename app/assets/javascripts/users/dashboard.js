$(function () {
  var pane = new ViewerPaneController({'selector' : '.user-container'});
  
  $('.user-info-out').live('click',function(evt){
    evt.preventDefault();
    var index = pane.hasChild('#' + 'user_' + this.id);
    if (index === -1){
    $.ajax({
       type: "GET",
       url: '/users/' + this.id + '/more_info',
       dataType: "html",
       success: function(data){
         var newLi = data;
         pane.addChild(newLi);
       },
       failure: function(){
        console.log("FUcked");
       }

     });
   }else{
     pane.skipTo(index);
   }
   
   
   
   
   
});

}); //end of file
