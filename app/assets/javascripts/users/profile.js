function UserProfile(config) {
  this._init(config);
}

UserProfile.prototype._init = function(config) {
  var that = this;
  this.config = config;
  this.currentUserId = config.currentUserId, this.forUserId = config.forUserId, this.userName = config.forUserName;
  this.commonPanelsContainer = $(config.commonPanelSelector);
  this.remainingPanelsContainer = $(config.remainingPanelSelector);
  this.userNameDom = $(config.nameSelector);

  $.ajax({
    url: "/panels/all/" + that.currentUserId + "/" + that.forUserId,
    type: "GET",
    dataType: "json",
    success: function(data) {
      that.commonPanels = data.commonPanels;
      that.remainingPanels = data.remainingPanels;
      that.panelsDictionary = data.panelsDictionary;
      that.populatePanels();
    }
  });
  this.populateQuestions();
};

UserProfile.prototype.populatePanels = function() {
  var ul = $('<ul>').addClass('story-tags'), that = this;
  $.each(this.commonPanels, function(i, cp) {
    var li = $('<li><a></a></li>');
    li.children('a').attr('href', cp);
    li.children('a').text(that.panelsDictionary[cp]);
    li.appendTo(ul);
  });
  ul.appendTo(this.commonPanelsContainer);

  if(!this.config.myProfile) {
    ul = $('<ul>').addClass('story-tags');
    $.each(this.remainingPanels, function(i, rp) {
      var li = $('<li><a></a></li>');
      li.children('a').attr('href', rp);
      li.children('a').text(that.panelsDictionary[rp]);
      li.appendTo(ul);
    });
    ul.appendTo(this.remainingPanelsContainer);
    this.userNameDom.text(this.userName);
  } else {
    this.remainingPanelsContainer.parent('li').remove();
    this.commonPanelsContainer.parent('li').find('p.shared-by').text("Your panels:");
  }
};

UserProfile.prototype.populateQuestions = function() {

};
