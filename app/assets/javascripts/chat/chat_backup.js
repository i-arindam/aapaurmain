function ChatConnector(config){
 this.config = config || {};
 
 //debug
 this.config.pusher_key = '4b87c0aa5ae5fa58eb8c';
 this.channel_name = this.config.channel_name || 'test';
 
 
 this._init(); 
}

// Send events on the channel.
ChatConnector.prototype.sendEventToServer = function( params, options ){
  params.socket_id  = this.pusher.socket_id;
  params.room       = this.channel_name;
  $.ajax({
    url:  '/chat/create_event',
    complete: function( request, status ){
      if( typeof options !== 'undefined' && typeof options.callback === "function" ){
        options.callback.call( options.scope || this, request.responseText, status );
      }
    },
    success: function(){
      console.log('send event success');
    },
    type: 'POST',
    dataType: 'json',
    async:  true,
    data: params
  });
};


ChatConnector.prototype._setUpSendMessage = function(){
  var that = this;
  $("#sendMessage").click(function(e) {
    if ($("#message").val().length !== 0) {
      that.sendMessage({
        to: "",
        room: that.channel_name,
        body: $("#message").val(),
        timeStamp: Math.round(new Date()/1000) //To measure delays in messages. Date.now() doesn't work in IE
      });
      addToHistory($("#message").val(), 'me');

      $("#message").val("");
    }
    $('#message').focus();

    e.preventDefault();
  });
};

// Send a message to room
ChatConnector.prototype.sendMessage = function(params){
  params.event_type = 'message_received';
  this.sendEventToServer( params );
};

ChatConnector.prototype._init = function(){
  var that = this;
  this.pusher = new Pusher( this.config.pusher_key );
  
  this.pusher.connection.bind('established', function(e){
     that.connected(e);
   });

   this.pusher.connection.bind('failed', function( e ){
     // this should show only reconnecting status and should not try to call 
     // eventProcessor.connect() as pusher itself does it.                                                        
     // that.handlers.reconnect( e );
     that.reconnecting( e );
   });

   // Handler for disconnection;
   this.pusher.connection.bind('disconnected', function( e ){
     // clear the member list in the UI for consistency
     that.disconnected( e );
   });

   // Return if already subscribed to a channel.
   if( typeof this.channel !== "undefined" ){
     return;
   }
   // use predefined channel name instead of currently passed ...
   this.channel = this.pusher.subscribe( this.channel_name );
   // Add handlers to listen to events on this channel.
   this.addEventHandlers();
   this._setUpSendMessage();
};

ChatConnector.prototype.addEventHandlers = function(){
  var that = this;
  this.channel.bind( "pusher:subscription_succeeded", function( users ){
    // that.roomJoined( that, users );
    console.log("subsc success");
   });

   // Handler for a new member added event
   // this.channel.bind( "pusher:member_added", function( user ){
   //    that.memberAdded( that, user);
   // });
   // 
   // // Handler for remove member event.
   // this.channel.bind( "pusher:member_removed", function( e ){
   //   that.memberRemoved( that, e );
   // });
   // 
   // Handler for a new message received event
   this.channel.bind( "message_received", function( e ) {
     that.message_received(e);
   });
   
   // 
   // this.channel.bind("presenter_leaving_room", function( e ){
   //   if( !that.config.is_presenter ) {
   //     that.disconnect( e );
   //   }
   // });
   // 
   // // Handler for channel_subscription_error
   // this.channel.bind('subscription_error', function(status) {
   //   if(status === 408 || status === 503){
   //     that.channel = that.pusher.subscribe(that.channel_name);
   //   }
   // });
   // // Not being used for now.
   // this.channel.bind( "message_sent", this.handlers.message_sent);
  
};

ChatConnector.prototype.disconnect = function( e ){
  // Handle the case of disconnection by presenter
  if ( this.config.is_presenter ) {
    // Show disconnecting animation for presenter
  } else {
    // Show disconnecting animation for viewer
  }
  cleanDisconnect = true;
  eventProcessor.disconnect();
  return false;
};

ChatConnector.prototype.connected = function( e ){
  
  console.log('connected');
  // eventProcessor.joinRoom( this.config.meeting_id );
  // 
  // // Disable quit meeting link
  // userActivity(false);
  // 
  // // Hide all connecting and disconnecting statuses
  // joiningStatus();


};

ChatConnector.prototype.reconnecting = function( e ){
  disconnectedStatus();
};

ChatConnector.prototype.reconnect = function( e ){
  // Disable quit meeting link
  userActivity(false);

  // Show disconnected status
  disconnectedStatus();

  window.reconnectInterval = window.setInterval(function() {
    if (window.reconnectCount > 0) {
      $("#reconnectTime").html(--window.reconnectCount);
    } else {
      // Reset timers
      window.reconnectCount = 5;
      window.clearInterval(window.reconnectInterval);

      // Connect
      eventProcessor.connect();

      // Hide disconnected status
      connectingStatus();
    }
  }, 1000);

  $("#reconnect").click(function(e) {
    e.preventDefault();
    window.clearInterval(window.reconnectInterval);

    eventProcessor.connect();

    // Disable quit meeting link
    userActivity(false);

    // Hide disconnected status
    connectingStatus();

    cleanDisconnect = false;
    return false;
  });

};
ChatConnector.prototype.disconnected = function(e) {
};
ChatConnector.prototype.message_received = function(e) {
  // Ignore if message was sent my self.
  // if (e.payload.user === this.config.nickname) {
  //   return false;
  // }
  // Add to chat history.
  e.payload.user = "user1";
  addToHistory( e.payload.message, e.payload.user, {'timeStamps':e.payload.timeStamps,
                                                    'type':'message_received'});
  return true;
};

function addToHistory(text, user, params) {
 
  // //Maintain a counter and remove older messages
  //  if(window.meetingsMsgCount == meetingConfig.max_message_count) {
  //    $('#chatBox #chat li:last-child').remove();
  //  } else {
  //    window.meetingsMsgCount++;
  //  }
  //  var selfClass = " ";
  //  if (user !== undefined && user != null){
  //    if (user !== 'me' && text.search(meetingConfig.nickname) != -1) {
  //      selfClass = " notice";
  //    }
  //    $('#chatBox #chat').prepend('<li class="chatText ' + (user === 'me' ? 'you' : '') + selfClass + '"><strong>' + user + ' &raquo;</strong> ' + urlify(text) + '</li>');
  //  } else {
     $('#chat').prepend('<li class="chatNotice">' + text + '</li>');
  //}
};




window.setupChat = function () {
  Pusher.log = function() {
    if (window.console) {
      window.console.log.apply(window.console, arguments);
    }
  };
  return new ChatConnector();
};
(function($) {
  $(document).ready(function() {
    setupChat();
  });
})(jQuery);