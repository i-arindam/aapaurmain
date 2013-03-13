function UserActions(config) {
  this.config = config;
  this._init();
}

UserActions.prototype._init = function() {
  this.buttons = $('.req-button');

  this.bindClickForRequestActions();
  
  if(this.config.singleUser) {
    this.setupFollowActions();
    this.setupRaty();
    this.bindRateClickAction();
  } else {
    this.writeFollowingStatus();
    this.setupFollowActions();
    this.writeRatings();
  }
};

UserActions.prototype.bindClickForRequestActions = function() {
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

  $('.request_outer.request_sorts input[type=button]').on('click', function(e) {
    e.preventDefault();
    that.confirm = $(this).hasClass("yes");
    $.colorbox.close();
  });  
};

UserActions.prototype.userSaidYesOrNoTo = function(link, uid) {
  var that = this;
  uid = uid || this.config.userId;
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

UserActions.prototype.updateButton = function(data, uid) {
  var li, buttonToUpdate;
  if(this.config.singleUser) {
    buttonToUpdate = $('.req-button');
  } else {
    li = $(this.config.userSelector).filter('[data-user-id=' + uid + ']');
    buttonToUpdate = li.find('a.req-button');
  }

  buttonToUpdate.attr('href', data.post_href);
  buttonToUpdate.attr('data-special', data.post_special);
  buttonToUpdate.find('span').text(data.post_text);
};

UserActions.prototype.writeFollowingStatus = function() {
  var that = this;
  var lis = $(that.config.sliderElement).children('li');
  $.ajax({
    url: '/get/follow/statuses',
    data: { 'user_ids': this.config.userIds },
    type: "GET",
    dataType: "json",
    success: function(data) {
      for(var uid in data) {
        if(data.hasOwnProperty(uid)){
          var follows = data[uid];
          var targetLi = lis.filter('[data-user-id=' + uid + ']');
          var thisUsersName = targetLi.attr('data-user-name');
          targetLi.find('.link-follow-user').attr('data-user-id', uid);
          if(follows) {
            targetLi.find('.link-follow-user').addClass('unfollow').attr('href', '#unfollow_user');
            targetLi.find('.link-follow-user').children('span').text('Unfollow ' + thisUsersName);
          } else {
            targetLi.find('.link-follow-user').addClass('follow').attr('href', '#follow_user');
            targetLi.find('.link-follow-user').children('span').text('Follow ' + thisUsersName);
          }
        }
      }
    }
  });
};

UserActions.prototype.setupFollowActions = function() {
  var that = this;
  
  $('.link-follow-user.follow, .link-follow-user.unfollow').live('click', function(e) {
    e.preventDefault();
    var btn = $(this);
    var uid = btn.attr('data-user-id');
    that.destUserName = btn.parents('li').attr('data-user-name') || that.config.userName;
    that.action = (btn.hasClass('follow') ? 'follow' : 'unfollow');
    that.actionText = (btn.hasClass('follow') ? 'Follow' : 'Unfollow');
    that.linkToFollow = '/' + that.action + '/user/' + uid;

    $($(this).attr('href')).find('span.user-name').text(that.destUserName);
    btn.colorbox({
      inline: true,
      width: "50%",
      title: "AapAurMain",
      onClosed: function() {
        that.showPostFollowMessage();
      }
    });
  });

  $('.request_outer.following_sorts input[type=button]').on('click', function(e) {
    e.preventDefault();
    that.confirmFollow = $(this).hasClass("yes");
    var srcObject = $.colorbox.element();
    $.colorbox.close();

    that.userFollowedOrNot(srcObject);
  });  
};

UserActions.prototype.showPostFollowMessage = function() {
  $.colorbox({
    html: this.postMessage,
    width: "50%",
    title: "AapAurMain"
  });
};

UserActions.prototype.userFollowedOrNot = function(jqObj) {
  var that = this;
  if(this.confirmFollow) {
    $.ajax({
      url: that.linkToFollow,
      type: "POST",
      success: function(data) {
        var messageDialog = $('#' + that.action + '_post_message');
        messageDialog.find('span.user-name').text(that.destUserName);
        that.postMessage = messageDialog.html();
        jqObj.toggleClass('follow unfollow');
        jqObj.find('span.follow-user').text(data.btn_text);
        jqObj.attr('href', data.btn_href);
      }
    });
  }  
};

UserActions.prototype.writeRatings = function() {
  var that = this;
  var lis = $(this.config.sliderElement).children('li');
  $.ajax({
    url: '/get/user/ratings',
    type: "GET",
    dataType: "json",
    data: {'user_ids': this.config.userIds },
    success: function(data) {
      var isReadOnly = false;
      for(var rate in data) {
        if(data.hasOwnProperty(rate)) {
          var targetLi = lis.filter('[data-user-id=' + rate + ']');
          targetLi.find('.avg-rate').text(data[rate].avg_rating);
          targetLi.find('.num-rate').text(data[rate].num_ratings);
          targetLi.find('.star').attr('data-score', data[rate].rated);
        }
      }
      that.setupRaty();
      that.bindRateClickAction();
    }
  });
};

UserActions.prototype.setupRaty = function() {
  var that = this;
  $('.star').raty({
    path: '/assets/users/',
    score: function() {
      return $(this).attr('data-score');
    },
    size: 48,
    target: '.rate-hint',
    targetKeep: true,
    targetText: '--',
    hints: ['Not great', 'Ok', 'Cool', 'Awesome', 'Kick Ass'],
    click: function(score, evt) {
      that.rateProfile(score, $(this).parents('li').attr('data-user-id') || that.config.userId);
    }
  });  
};

UserActions.prototype.bindRateClickAction = function() {
  var that = this;
  $('.link-rate-profile').on('click', function(e) {
    e.preventDefault();
    if(that.config.singleUser) {
      $('.rate-hint, .ratings, .star').fadeIn(700);
    } else {
      var targetLi = $(this).parents('li');
      targetLi.find('.rate-hint, .ratings, .star').fadeIn(700);
    }
  });
};

UserActions.prototype.rateProfile = function(score, uid) {
  var that = this, rateData = {};
  var postUrl = '/rate/profile/' + uid + '/' + score;

  $.ajax({
    url: postUrl,
    type: "POST",
    dataType: "json",
    data: rateData,
    success: function(data) {
      var target;
      if(that.config.singleUser) {
        target = $('.ratings');
      } else {
        target = $(that.config.sliderElement).children('li').filter('[data-user-id=' + uid + ']');
      }
      target.find('.avg-rate').text(data.new_avg);
      target.find('.num-rate').text(data.new_count);
    }
  });
};
