function RequestActions() {
  this._init();
}

RequestActions.prototype._init = function() {
  this.buttons = $('.req-button');

  this.bindClickActions();
};

RequestActions.prototype.bindClickActions = function() {
  var that = this;
  this.buttons.on('click', function(e) {
    e.preventDefault();
    var url = $(this).attr('href'), specialAction;
    if (url === "#") {
      specialAction = $(this).attr('data-special');
      that.showSpecialAction(specialAction);
    } else {
      that.makeBackendCall(url);
    }
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

RequestActions.prototype.showSpecialAction = function(action) {
  if(action === "withdrawn" || action === "declined") {
    alert('Cannot send request again. Last one was ' + action);
  } else if(action === "break_lock") {
    
  }
};
