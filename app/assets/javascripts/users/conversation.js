$(function() {
  $('.newMessage form').submit(function(e) {
    e.preventDefault();
    var convId = $('.convId').attr('value');
    var newMessageUrl = "/conversations/" + convId + "/new_message";
    
    $.ajax({
      url: newMessageUrl,
      data: $('form').serialize(),
      type: 'POST',
      success: function(data) {
        if(data.status) {
          var li = $('<li/>').addClass('messageContainer myColor');
          $('<img/>').attr('src', 'http://placehold.it/50x50').appendTo(li);
          
          var infoDiv = $('<div />').addClass('info');
          $('<span/>').addClass('name').html(data.name).appendTo(infoDiv);
          $('<span/>').addClass('date pull-right').html(data.date).appendTo(infoDiv);
          $('<span/>').addClass('time pull-right').html(data.time).appendTo(infoDiv);
          $(infoDiv).appendTo(li);
          
          $('<div/>').addClass('text').html(data.text).appendTo(li);

          // To create the display list if its not present,
          if($('ul.conversationList').length === 0) {
            $('<ul/>').addClass('conversationList').prependTo('div.newMessage');
            $('div.messageFiller').hide();
          }

          $('ul.conversationList').append(li);
          $('textarea').val('');
        } else {
          alert(data.message);
        }
      }, error: function(data) {
        alert("Sorry the message could not be posted because of some technical error. Try again in some time?");
      }
    }); // $.ajax
  }); // form.submit
  
}); // $function
