function UserActions() {
  this.setupActions();
};

UserActions.prototype.requestStates = { 
  'newRequestSent' : {
    'selector' : '.j-send-request',
    'classToAdd' : 'j-withdraw-request btn-danger',
    'classToRemove' : 'btn-success j-send-request',
    'newTitle' : 'Withdraw Request',
  },
  'requestWithdrawn' : {
    'selector' : '.j-withdraw-request',
    'classToAdd' : 'j-send-request btn-success',
    'classToRemove' : 'btn-danger j-withdraw-request',
    'newTitle' : 'Send Request'
  },
  'requestAccepted' : {
    'selector' : '.j-accept-request',
    'classToAdd' : 'j-withdraw-lock btn-danger',
    'classToRemove' : 'btn-success j-accept-request',
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
    that.actionButton = this;
    evt.preventDefault();
    evt.stopPropagation();
    var to_id = user_object.to_user_id || this.id.split("-")[1]
    bootbox.confirm("Are you sure?", function(confirmed) {
                        console.log("Confirmed: "+confirmed);
                        if (confirmed){

      $.ajax({
        url : 'create_request' ,
        data : {
          "from_id" : user_object.session_user_id,
          "to_id" : to_id
        }, type : 'POST',
        dataType : 'json',
        success : function(data){
          console.log('success');
          bootbox.alert(data.message);
          $('#withdraw-'+to_id).show();
          $('#send-'+to_id).hide();
          $('#decline-'+to_id).hide();
          $('#accept-'+to_id).hide();
          $('#lock-'+to_id).hide();
          //that.setupRequestButton(that.requestStates.newRequestSent,that.actionButton);
        }, error : function(data){
          bootbox.alert(data.message);
        }
      });
    }
    });
  });
};

UserActions.prototype.setupWithdraw = function(){
  var that = this;
  $('.j-withdraw-request').live('click',function(evt){
    that.actionButton = this;
    evt.preventDefault();
    evt.stopPropagation();
    var to_id = user_object.to_user_id || this.id.split("-")[1];
    bootbox.confirm("Are you sure?", function(confirmed) {
                        console.log("Confirmed: "+confirmed);
      if (confirmed){
        $.ajax({
          url : 'withdraw_request' ,
          data :  {
            "from_id" : user_object.session_user_id,
            "to_id" : to_id
          },
          type : 'POST' ,
          dataType : 'json',
          success : function(data){
            console.log('success');
            bootbox.alert(data.message);
            $('#send-'+to_id).show();
            $('#withdraw-'+to_id).hide();
            $('#decline-'+to_id).hide();
            $('#accept-'+to_id).hide();
            $('#lock-'+to_id).hide();
            //that.setupRequestButton(that.requestStates.requestWithdrawn,that.actionButton);
          }, error : function(data){
            bootbox.alert(data.message);
          }
        });
      }
    });
  });
};

UserActions.prototype.setupAccept = function(){
  var that = this;
  $('.j-accept-request').live('click',function(evt){
    that.actionButton = this;
    var to_id = user_object.to_user_id || this.id.split("-")[1];
    evt.preventDefault();
    evt.stopPropagation();
    bootbox.confirm("Are you sure?", function(confirmed) {
                          console.log("Confirmed: "+confirmed);
      if (confirmed){
        $.ajax({
          url : 'accept_request' ,
          data :  {
            "from_id" : to_id,
            "to_id" : user_object.session_user_id
          },
          type : 'POST' ,
          dataType : 'json',
          success : function(data){
            console.log('success');
            bootbox.alert(data.message);
            $('#send-'+to_id).hide();
            $('#withdraw-'+to_id).hide();
            $('#decline-'+to_id).hide();
            $('#accept-'+to_id).hide();
            $('#lock-'+to_id).show();
            //that.setupRequestButton(that.requestStates.requestAccepted, that.actionButton);
          }, error : function(data){
            bootbox.alert(data.message);
          }
        });
      }
    });    
  });
};

UserActions.prototype.setupDecline = function(){
  var that = this;
  $('.j-decline-request').live('click',function(evt){

    that.actionButton = this;
    var to_id = user_object.to_user_id || this.id.split("-")[1];
    evt.preventDefault();
    evt.stopPropagation();
    bootbox.confirm("Are you sure?", function(confirmed) {
                          console.log("Confirmed: "+confirmed);
      if (confirmed){
        $.ajax({
          url : 'decline_request' ,
          data :  {
            "to_id" : user_object.session_user_id,
            "from_id" : to_id
          },
          type : 'POST' ,
          dataType : 'json',
          success : function(data){
            console.log('success');
            bootbox.alert(data.message);
            $('#send-'+to_id).hide();
            $('#withdraw-'+to_id).hide();
            $('#decline-'+to_id).hide();
            $('#accept-'+to_id).hide();
            $('#lock-'+to_id).hide();
            //that.actionButton.hide();
           // that.hide();
          }, error : function(data){
            bootbox.alert(data.message);
          }
        });
      }
    });
  });
};

UserActions.prototype.setupWithdrawLock = function(){
  $('.j-withdraw-lock').live('click',function(evt){
    that.actionButton = this;
    var to_id = user_object.to_user_id || this.id.split("-")[1];
    evt.preventDefault();
    evt.stopPropagation();
    bootbox.confirm("Are you sure?", function(confirmed) {
                          console.log("Confirmed: "+confirmed);
      if (confirmed){    
        $.ajax({
          url : 'withdraw_lock' ,
          data :  {
            "from_id" : user_object.session_user_id,
            "to_id" : to_id
          },
          type : 'POST' ,
          dataType : 'json',
          success : function(data){
            console.log('success');
            bootbox.alert(data.message);
            $('#send-'+to_id).hide();
            $('#withdraw-'+to_id).hide();
            $('#decline-'+to_id).hide();
            $('#accept-'+to_id).hide();
            $('#lock-'+to_id).hide();
          }, error : function(data){
            bootbox.alert(data.message);
          }
        });
      }
    });
  });
  
};

UserActions.prototype.setupRequestButton = function(requestObject, selector){
  var requestButton = $(selector); 
  requestButton.attr({
    'value' : requestObject.newTitle          
  });

  requestButton.addClass(requestObject.classToAdd); 
  requestButton.removeClass(requestObject.classToRemove);
};

