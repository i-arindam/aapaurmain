function ListView(config) {
  this.config = config;
  this.initSlider();
  this._getDomPartials();
  this._initStructures();
  this.getAllData();
}

ListView.prototype.initSlider = function() {
  var that = this;

  $(this.config.sliderElement).refineSlide({
    transition: 'custom',
    customTransitions: [ 'cubeH', 'cubeV'],
    autoPlay: false,
    keyNav: true,
    transitionDuration: 500,
    arrowTemplate: '<div class="rs-arrows"><a href="#" class="rs-prev"></a><a href="#" class="rs-next"></a></div>',
    controls: 'arrows',
    afterChange: function() {
      $('.rs-prev, .rs-next').addClass('disable-action');
      that.bindDisplayChange(this.slider);
    },
    onInit: function() {
      that.storeUserDetails();
    }
  });  
};

ListView.prototype.storeUserDetails = function() {
  var lis = $(this.config.sliderElement).children('li'), that = this;
  this.userInfo = {};
  $.each(lis, function(i, dom) {
    var uid = $(dom).attr('data-user-id'), uname = $(dom).attr('data-user-name');
    that.userInfo[uid] = uname;
  });
};

ListView.prototype._getDomPartials = function() {
  var getUrl = "/get/dom/all", that = this;
  $.ajax({
    url: getUrl,
    type: "GET",
    dataType: "json",
    success: function(data) {
      that.storyDom = $(data.story_partial);
      that.questionDom = $(data.question_partial);
      that.panelDom = $(data.panel_partial);
      that.panelsDictionary = data.panels;
    }, error: function(data) {
      var x = 10;
    }
  });
};

ListView.prototype._initStructures = function() {  
  this.activeUserId = this.config.sessionUserId;
  this.firstUserId = this.config.userIds[0];

  this.panelsContainer = $('ul.panels');
  this.topStoriesContainer = $('ul.story-container');
  this.questionsContainer = $('ul.questions');

  this.panelsLoader = $('div.panels-loader');
  this.storiesLoader = $('div.top-stories-loader');
  this.questionsLoader = $('div.questions-loader');

  this.panelsData = {};
  this.questionsData = {};
  this.topStoriesData = {};

  this.OBJECTS_HASH = {
    'panel': {
      'url': '/panels/all/{{sessionUserId}}/{{forUserId}}',
      'result': this.panelsData,
      'callback': this.paintPanelsSectionFor
    },
    'question': {
      'url': '/questions/latest/{{forUserId}}/2',
      'result': this.questionsData,
      'callback': this.paintQuestionsSectionFor
    },
    'story': {
      'url': '/stories/all/{{forUserId}}',
      'result': this.topStoriesData,
      'callback': this.paintTopStoriesSectionFor
    }
  };

  this.writeFollowingStatus();
  this.setupFollowActions();
  this.writeRatings();
  this.setupRatings();
};

ListView.prototype.getAllData = function() {
  var that = this;
  var userIds = this.config.userIds;
  
  /* placing further requests fetching on queue, return execution */
  setTimeout(function() {
    $.each(userIds, function(i, uid) {
      setTimeout(function() {
        that.getDataFor('panel', uid);
        that.getDataFor('question', uid);
        that.getDataFor('story', uid);
      }, 100);
    });
  }, 100);
};

ListView.prototype.getDataFor = function(object, uid, useCallback) {
  var that = this ;
  var getUrl = this.OBJECTS_HASH[object]['url']
  .replace('{{sessionUserId}}', this.activeUserId).replace('{{forUserId}}', uid);
  var resultSet = this.OBJECTS_HASH[object]['result'];
  var callbackHandler = this.OBJECTS_HASH[object]['callback'];
  
  $.ajax({
    url: getUrl,
    type: "GET",
    dataType: "json",
    success: function(data) {
      resultSet[uid] = data;
      if(uid === that.firstUserId) {
        callbackHandler.call(that, uid);
      }
      if(useCallback) {
        that.call(callbackHandler, uid);
      }
    }, error: function(data) {
      resultSet[uid] = null;
    }
  });
};

ListView.prototype.bindDisplayChange = function(slider) {
  var that = this, showingElement = slider.currentPlace;
  var currentLi = $(this.config.sliderElement).children('li').get(showingElement);
  var newUserId = $(currentLi).attr('data-user-id');
  setTimeout(function() {
    that.clearContentAndShowLoader();
    that.refreshDisplayFor(newUserId);
  }, 100);
};

ListView.prototype.clearContentAndShowLoader = function() {
  this.panelsContainer.children().remove();
  this.questionsContainer.children().remove();
  this.topStoriesContainer.children().remove();

  this.panelsLoader.appendTo(this.panelsContainer).fadeIn();
  this.questionsLoader.appendTo(this.questionsContainer).fadeIn();
  this.storiesLoader.appendTo(this.topStoriesContainer).fadeIn();
};

ListView.prototype.refreshDisplayFor = function(uid) {
  this.panelsData[uid] ? this.paintPanelsSectionFor(uid) : this.retryAndPaintFor('panel', uid);
  this.questionsData[uid] ? this.paintQuestionsSectionFor(uid) : this.retryAndPaintFor('question', uid);
  this.topStoriesData[uid] ? this.paintTopStoriesSectionFor(uid) : this.retryAndPaintFor('story', uid);
  $('.rs-next, .rs-prev').removeClass('disable-action');
};

ListView.prototype.retryAndPaintFor = function(obj, uid) {
  this.getDataFor(obj, uid, true);
};

ListView.prototype.paintPanelsSectionFor = function(uid) {
  if(this.constructedDomForPanels && this.constructedDomForPanels[uid] ) {
    this.panelsLoader.hide();
    this.constructedDomForPanels[uid].appendTo(this.panelsContainer);
    return;
  } 
  var data = this.panelsData[uid], that = this, commonPanelLi, remainingPanelLi;
  var commonPanels = data.commonPanels;
  var otherPanels = data.remainingPanels;
  var uname = this.userInfo[uid];
  var domObj = this.panelDom.clone();
  var commonPanelDom = domObj.find('.datas.common-panels');
  var otherPanelDom = domObj.find('.datas.other-panels');
  var cLiUl = $('<ul/>').addClass('story-tags'), oLiUl = cLiUl.clone();

  domObj.find('.shared-by span.other-user').text(uname);
  
  if(commonPanels) {
    $.each(commonPanels, function(i, cp) {
      var li = $('<li><a></a></li>');
      li.children('a').attr('href', '/panels/' + cp);
      li.children('a').text(that.panelsDictionary[cp]);
      li.appendTo(cLiUl);
    });
    cLiUl.appendTo(commonPanelDom);
  }
  if(otherPanels) {
    $.each(otherPanels, function(i, rp) {
      var li = $('<li><a></a></li>');
      li.children('a').attr('href', '/panels/' + rp);
      li.children('a').text(that.panelsDictionary[rp]);
      li.appendTo(oLiUl);
    });
    oLiUl.appendTo(otherPanelDom);
  }
  this.panelsLoader.hide();
  if(!commonPanels && !remainingPanels) {
    domObj = $('<h3/>').addClass('no-content').text("Sorry no panels info found for " + uname);
  }
  domObj.appendTo(this.panelsContainer);
  this.constructedDomForPanels = this.constructedDomForPanels || {};
  this.constructedDomForPanels[uid] = domObj;
};

ListView.prototype.paintQuestionsSectionFor = function(uid) {
  var that = this;
  if(that.constructedDomForQuestions && that.constructedDomForQuestions[uid]) {
    this.questionsLoader.hide();
    $.each(this.constructedDomForQuestions[uid], function(i, q) {
      q.appendTo(that.questionsContainer);
    });
    return;
  }

  this.constructedDomForQuestions = this.constructedDomForQuestions || {};
  var data = this.questionsData[uid], uname = this.userInfo[uid];
  this.questionsLoader.hide();

  if(data.answers.length === 0) {
    $('<h3/>').addClass('no-content').text("Sorry no questions found for " + uname).appendTo(this.questionsContainer);
  } else {
    this.constructedDomForQuestions[uid] = [];
    $.each(data.answers, function(i, an) {
      var questionDom = that.questionDom.clone();
      questionDom.find('.q-text').text(an.q);
      questionDom.find('.a-text').text(an.a);

      that.constructedDomForQuestions[uid].push(questionDom);
      questionDom.appendTo(that.questionsContainer);
    });
  }
};

ListView.prototype.paintTopStoriesSectionFor = function(uid) {
  var that = this;
  if(this.constructedDomForStories && this.constructedDomForStories[uid]) {
    this.storiesLoader.hide();
    $.each(this.constructedDomForStories[uid], function(i, sDom) {
      sDom.appendTo(that.topStoriesContainer);
    });
    return;
  }

  this.constructedDomForStories = this.constructedDomForStories || {};
  var data = this.topStoriesData[uid], uname = this.userInfo[uid];
  this.storiesLoader.hide();

  if(data.stories.length === 0) {
    $('<h3/>').addClass('no-content').text("Sorry no stories found for " + uname).appendTo(this.topStoriesContainer);    
  } else {
    this.constructedDomForStories[uid] = [];
    $.each(data.stories, function(i, s) {
      var storyDom = that.storyDom.clone();
      storyDom.find('.story-creator').text(s.by);
      storyDom.find('.story-time').text(s.when);
      storyDom.find('.story-text').text(s.text);
      storyDom.find('.story-claps').text(s.claps);
      storyDom.find('.story-boos').text(s.boos);
      storyDom.find('.story-comments').text(s.comments);

      var panelsUl = storyDom.find('ul.story-tags');

      $.each(s.panels, function(i, p) {
        var li = $('<li/>');
        $('<a>').attr('href', '/panels/' + p).text(that.panelsDictionary[p]).appendTo(li);
        li.appendTo(panelsUl);
      });
      
      that.constructedDomForStories[uid].push(storyDom);
      storyDom.appendTo(that.topStoriesContainer);
    });
  }
};

ListView.prototype.writeFollowingStatus = function() {
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
            targetLi.find('.link-follow-user').addClass('unfollow');
            targetLi.find('.link-follow-user').children('span').text('Unfollow ' + thisUsersName);
          } else {
            targetLi.find('.link-follow-user').addClass('follow');
            targetLi.find('.link-follow-user').children('span').text('Follow ' + thisUsersName);
          }
        }
      }
    }
  });
};

ListView.prototype.setupFollowActions = function() {
  var that = this;
  
  $('.link-follow-user.follow, .link-follow-user.unfollow').live('click', function(e) {
    e.preventDefault();
    var btn = $(this);
    var destUserId = btn.attr('data-user-id'), destUserName = btn.parents('li').attr('data-user-name');
    var action = (btn.hasClass('follow') ? 'follow' : 'unfollow');
    var actionInSentence = action.charAt(0).toUpperCase() + action.slice(1);
    var ok = confirm(actionInSentence + " " + destUserName + "'s activities?");
    if(ok) {
      $.ajax({
        url: '/' + action + '/user/' + destUserId,
        type: "POST",
        success: function(data) {
          var msg;
          if(action === 'follow') {
            msg = "Awesome. You can now find " + destUserName + " in your dashboard and through the left panel";
            btn.children('span').text('Unfollow ' + destUserName);
          } else {
            msg = "You can no longer keep track of " + destUserName;
            btn.children('span').text('Follow ' + destUserName);
          }
          alert(msg);
          btn.toggleClass('follow unfollow');
        }
      });
    }
  });
};

ListView.prototype.writeRatings = function() {
  var that = this;
  var lis = $(this.config.sliderElement).children('li');
  $.ajax({
    url: '/get/user/ratings',
    type: "GET",
    dataType: "json",
    data: {'user_ids': this.config.userIds },
    success: function(data) {
      for(var rate in data) {
        if(data.hasOwnProperty(rate)) {
          var targetLi = lis.filter('[data-user-id=' + rate + ']');
          targetLi.find('.avg-rate').text(data[rate].avg_rating);
          targetLi.find('.num-rate').text(data[rate].num_ratings);
          targetLi.find('.star').attr('data-score', data[rate].avg_rating);
        }
      }
      $('.star').raty({
        path: '/assets/users/',
        size: 48,
        target: '.rate-hint',
        targetKeep: true,
        targetText: '--',
        hints: ['Not great', 'Ok', 'Cool', 'Awesome', 'Superrrr'],
        click: function(score, evt) {
          that.rateProfile(score, $(this).parents('li').attr('data-user-id'));
        }
      }); //{
    }
  });
};

ListView.prototype.setupRatings = function() {
  var that = this;
};

ListView.prototype.rateProfile = function(score, uid) {
  var that = this, rateData = {};
  var postUrl = '/rate/profile/' + uid + '/' + score;

  $.ajax({
    url: postUrl,
    type: "POST",
    dataType: "json",
    data: rateData,
    success: function(data) {
      var targetLi = $(that.config.sliderElement).children('li').filter('[data-user-id=' + uid + ']');
      targetLi.find('.avg-rate').text(data.new_avg);
      targetLi.find('.num-rate').text(data.new_count);
      targetLi.find('.star').raty('readOnly', true);
    }
  });
};
