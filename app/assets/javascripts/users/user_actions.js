function UserActions(config) {
  this.config = config;
  this._init();
}

UserActions.prototype._init = function() {
  this.buttons = $('.req-button');

  $('.text-blk p').fitText(1.2);
  this.bindClickForRequestActions();
  var that = this;
  $('.bpopup a.close').live('click', function(e) {
    $(that.popupElement).bPopup().close();
  });
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
  // Many a hacks involved.
  // On every popup open, all its input buttons are removed user-clicked class
  // on user click, that class is added
  // on close by any kind, if both user clicked and user clicked yes, only then carry out action
  var that = this, action, name, linkToFollow, uid;
  this.buttons.on('click', function(e) {
    e.preventDefault();
    action = $(this).attr('href');
    name = $(this).attr('data-user-name');
    linkToFollow = $(this).attr('data-special')
    uid = $(this).parents('li').attr('data-user-id');
    
    $(action).find('span.user-name').text(name);
    $(action).bPopup({
      opacity: 0.9,
      followSpeed: 300,
      fadeSpeed: 700,
      position: [500, 'auto'],
      positionStyle: 'absolute',
      easing: 'easeOutBack',
      speed: 450,
      transition: 'slideDown',
      onOpen: function() {
        that.popupElement = $(action);
        $(action).find('input[type=button]').removeClass('user-clicked');
      },
      onClose: function() {
        that.confirm = that.confirm && $(action).find('input[type=button]').hasClass('user-clicked');
        that.userSaidYesOrNoTo(linkToFollow, uid);
      }
    });
  });

  $('.request_outer.request_sorts input[type=button]').on('click', function(e) {
    e.preventDefault();
    $(this).addClass('user-clicked');
    that.confirm = $(this).hasClass("yes");
    that.popupElement.bPopup().close();
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
    that.linkToFollow = '/' + that.action + '/user/' + uid;
    that.followTarget = $($(this).attr('href'));
    that.followTarget.find('span.user-name').text(that.destUserName);
    
    that.followTarget.bPopup({
      opacity: 0.9,
      followSpeed: 300,
      fadeSpeed: 700,
      position: [500, 'auto'],
      positionStyle: 'absolute',
      easing: 'easeOutBack',
      speed: 450,
      transition: 'slideDown',
      onOpen: function() {
        that.popupElement = that.followTarget;
        that.followButton = btn;
        that.popupElement.find('input[type=button]').removeClass('user-clicked');
      },
      onClose: function() {
        that.confirmFollow = that.confirmFollow && that.popupElement.find('input[type=button]').hasClass('user-clicked');
        // that.showPostFollowMessage();
      }
    });
  });

  $('.request_outer.following_sorts input[type=button]').on('click', function(e) {
    e.preventDefault();
    that.confirmFollow = $(this).hasClass("yes");
    $(this).addClass('user-clicked');
    that.popupElement.bPopup().close();

    that.userFollowedOrNot(that.followButton);
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
        jqObj.toggleClass('follow unfollow');
        jqObj.find('span.follow-user').text(data.btn_text);
        jqObj.attr('href', data.btn_href);
        that.popupElement = messageDialog;
        // setTimeout(function() {
          $(messageDialog).bPopup({
            opacity: 0.9,
            followSpeed: 300,
            fadeSpeed: 700,
            position: [500, 'auto'],
            positionStyle: 'absolute',
            easing: 'easeOutBack',
            speed: 450,
            transition: 'slideDown'          
          });
        // }, 500);
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
