function UserActions() {
  this.setupActions();
};

UserActions.prototype.requestStates = { 
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

UserActions.prototype.setupActions = function() {
  this.setupSend();
  this.setupWithdraw();
  this.setupDecline();
  this.setupAccept();
  this.setupWithdraw();
};

UserActions.prototype.setupSend = function(){
  var that = this;
  $('.j-send-request').live('click',function(evt){
    evt.preventDefault();
    evt.stopPropagation();
    
    $.ajax({
      url : 'create_request' ,
      data : {
        "from_id" : user_object.session_user_id,
        "to_id" : user_object.to_user_id
      }, type : 'POST',
      dataType : 'json',
      success : function(data){
        console.log('success');
        alert(data.message);
        setupRequestButton(that.requestStates.newRequestSent);
      }, error : function(data){
        alert(data.message);
      }
    });
  });
};

UserActions.prototype.setupWithdraw = function(){
  $('.j-withdraw-request').live('click',function(evt){
    var that = this;
    evt.preventDefault();
    evt.stopPropagation();
    
    $.ajax({
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
        setupRequestButton(that.requestStates.requestWithdrawn);
      }, error : function(data){
        alert(data.message);
      }
    });
  });
};

UserActions.prototype.setupAccept = function(){
  $('.j-accept-request').live('click',function(evt){
    var that = this;
    evt.preventDefault();
    evt.stopPropagation();
    
    $.ajax({
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
        setupRequestButton(that.requestStates.requestAccepted);
      }, error : function(data){
        alert(data.message);
      }
    });
  });
};

UserActions.prototype.setupDecline = function(){
  $('.j-decline-request').live('click',function(evt){
    var that = this;
    evt.preventDefault();
    evt.stopPropagation();
    
    $.ajax({
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
      }, error : function(data){
        alert(data.message);
      }
    });
  });
};

UserActions.prototype.setupWithdrawLock = function(){
  $('.j-withdraw-lock').live('click',function(evt){
    evt.preventDefault();
    evt.stopPropagation();
    
    $.ajax({
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
      }, error : function(data){
        alert(data.message);
      }
    });
  });
  
};

UserActions.prototype.setupRequestButton = function(requestObject){
  var requestButton = $(requestObject.selector); 
  requestButton.attr({
    'value' : requestObject.newTitle          
  });

  requestButton.addClass(requestObject.classToAdd); 
  requestButton.removeClass(requestObject.classToRemove);
};

