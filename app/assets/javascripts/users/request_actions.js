function RequestActions() {
  this._init();
}

RequestActions.prototype._init = function() {
  this.buttons = $('.req-button');

  this.bindClickActions();
};

RequestActions.prototype.bindClickActions = function() {
  var that = this, action, name;
  this.buttons.on('click', function(e) {
    e.preventDefault();
    action = $(this).attr('href');
    name = $(this).attr('data-user-name');
    var div = $(action);
    div.find('span.user-name').text(name);
    $(this).colorbox({
      inline: true,
      width: "50%"
    });
    that.trackUserActionOn(action);
  });
};

RequestActions.prototype.makeBackendCall = function(url) {
  var that = this;
  $.ajax({
    url: url,
    type: "POST",
    success: function(data) {
      alert(data.message);
    }, error: function(data) {
      alert("Server Error");
    }
  });
};

RequestActions.prototype.userSaidYesOrNoTo = function(action, confirm) {
  var that = this;
};

RequestActions.prototype.trackUserActionOn = function(action) {
  var that = this;
  $('.request_outer input[type=button]').on('click', function(e) {
    e.preventDefault();
    var confirm = $(this).hasClass("yes");
    $.colorbox.close();
    that.userSaidYesOrNoTo(action, confirm);
  });
};
