function RequestActions(config) {
  this.config = config;
  this._init();
}

RequestActions.prototype._init = function() {
  this.buttons = $('.req-button');

  this.bindClickActions();
};

RequestActions.prototype.bindClickActions = function() {
  var that = this, action, name, linkToFollow, uid;
  this.buttons.on('click', function(e) {
    e.preventDefault();
    action = $(this).attr('href');
    name = $(this).attr('data-user-name');
    linkToFollow = $(this).attr('data-special')
    uid = $(this).parents('li').attr('data-user-id');
    
    $(action).find('span.user-name').text(name);
    $(this).colorbox({
      inline: true,
      width: "50%",
      title: "AapAurMain",
      onClosed: function() {
        that.userSaidYesOrNoTo(linkToFollow, uid);
      }
    });
  });

  $('.request_outer input[type=button]').on('click', function(e) {
    e.preventDefault();
    that.confirm = $(this).hasClass("yes");
    $.colorbox.close();
  });  
};

RequestActions.prototype.userSaidYesOrNoTo = function(link, uid) {
  var that = this;
  if(this.confirm) {
    $.ajax({
      url: link,
      type: "POST",
      dataType: "json",
      success: function(data) {
        that.updateButton(data, uid);
      }, error: function() {
        alert("Server Error. Looking into it.");
      }
    });
  }
};

RequestActions.prototype.updateButton = function(data, uid) {
  var li = $(this.config.userSelector).filter('[data-user-id=' + uid + ']');
  var buttonToUpdate = li.find('a.req-button');

  buttonToUpdate.attr('href', data.post_href);
  buttonToUpdate.attr('data-special', data.post_special);
  buttonToUpdate.find('span').text(data.post_text);
};
