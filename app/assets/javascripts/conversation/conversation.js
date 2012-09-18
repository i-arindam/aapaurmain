$(function() {
  $('form').submit(function(e) {
    e.preventDefault();
    var convId = $('.convId').attr('value');
    var newMessageUrl = "" + convId + "/new_message";
    
    $.ajax({
      url: newMessageUrl,
      data: $('form').serialize(),
      type: 'POST',
      success: function(data) {
        if(data.status) {
          var li = $('<li/>').addClass('messageContainer myColor');
          $('<img/>').attr('src', 'http://placehold.it/96x96').appendTo(li);
          
          var infoDiv = $('<div />').addClass('info');
          $('<span/>').addClass('name').html(data.name).appendTo(infoDiv);
          $('<span/>').addClass('time pull-right').html(data.time).appendTo(infoDiv);
          $(infoDiv).appendTo(li);
          
          $('<span/>').addClass('text').html(data.text).appendTo(li);
          $('ul.messages').append(li);
          $('textarea').val('');
        } else {
          alert(data.message);
        }
      }, error: function(data) {
        alert("10");
      }
    }); // $.ajax
  }); // form.submit
  
}); // $function