(function(){
var requestStates = { 
  'newRequestSent' : {
    'selector' : '.j-send-request',
    'classToAdd' : 'j-withdraw-request btn-danger',
    'classToRemove' : 'btn-success j-send-request',
    'newTitle' : 'Withdraw Request'
  },
  'requestWithdrawn' : {
    'selector' : '.j-withdraw-request',
    'classToAdd' : 'j-send-request btn-success',
    'classToRemove' : 'btn-danger j-withdraw-request',
    'newTitle' : 'Send Request'
  },
  'requestAccepted' : {
    'selector' : '.j-withdraw-lock',
    'classToAdd' : 'j-send-request btn-danger',
    'classToRemove' : 'btn-success j-withdraw-lock',
    'newTitle' : 'Withdraw Lock'
  },
  
  
};

sendRequest = function(){
  jQuery('.j-send-request').live('click',function(evt){
    evt.preventDefault();
    evt.stopPropagation();
    
    jQuery.ajax({
      url : 'create_request' ,
      data :  {
                "from_id" : user_object.session_user_id,
                "to_id" : user_object.to_user_id
              },
      type : 'POST' ,
      dataType : 'json',
      success : function(data){
        console.log('success');
        alert(data.message);
        setupRequestButton(requestStates.newRequestSent);
      },
      failure : function(data){
        alert(data.message);
      }
    });
  });
};

withdrawRequest = function(){
  jQuery('.j-withdraw-request').live('click',function(evt){
    evt.preventDefault();
    evt.stopPropagation();
    
    jQuery.ajax({
      url : 'withdraw_request' ,
      data :  {
                "from_id" : user_object.session_user_id,
                "to_id" : user_object.to_user_id
              },
      type : 'POST' ,
      dataType : 'json',
      success : function(data){
        console.log('success');
        alert(data.message);
        setupRequestButton(requestStates.requestWithdrawn);
      },
      failure : function(data){
        alert(data.message);
      }
    });
  });
};

acceptRequest = function(){
  jQuery('.j-accept-request').live('click',function(evt){
    var that = this;
    evt.preventDefault();
    evt.stopPropagation();
    
    jQuery.ajax({
      url : 'accept_request' ,
      data :  {
                "from_id" : user_object.session_user_id,
                "to_id" : user_object.to_user_id
              },
      type : 'POST' ,
      dataType : 'json',
      success : function(data){
        console.log('success');
        alert(data.message);
        setupRequestButton(requestStates.requestAccepted);
      },
      failure : function(data){
        alert(data.message);
      }
    });
  });
};

declineRequest = function(){
  jQuery('.j-decline-request').live('click',function(evt){
    var that = this;
    evt.preventDefault();
    evt.stopPropagation();
    
    jQuery.ajax({
      url : 'decline_request' ,
      data :  {
                "from_id" : user_object.session_user_id,
                "to_id" : user_object.to_user_id
              },
      type : 'POST' ,
      dataType : 'json',
      success : function(data){
        console.log('success');
        alert(data.message);
        that.hide();
        
      },
      failure : function(data){
        alert(data.message);
      }
    });
  });
};

withdrawLock = function(){
  jQuery('.j-withdraw-lock').live('click',function(evt){
    evt.preventDefault();
    evt.stopPropagation();
    
    jQuery.ajax({
      url : 'withdraw_lock' ,
      data :  {
                "from_id" : user_object.session_user_id,
                "to_id" : user_object.to_user_id
              },
      type : 'POST' ,
      dataType : 'json',
      success : function(data){
        console.log('success');
        alert(data.message);
      },
      failure : function(data){
        alert(data.message);
      }
    });
  });
  
};

setupRequestButton = function(requestObject){
     var requestButton = jQuery(requestObject.selector); 
      requestButton.attr({
        'value' : requestObject.newTitle          
      });
      
    requestButton.addClass(requestObject.classToAdd); 
    requestButton.removeClass(requestObject.classToRemove);
};

sendRequest();
withdrawRequest();
acceptRequest();
declineRequest();
withdrawLock();

})();




  
