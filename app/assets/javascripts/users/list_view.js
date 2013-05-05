function ListView(config) {
  this.config = config;
  this.initSlider();
  this._getDomPartials();
  this._initStructures();
  this.getAllData();
}

ListView.prototype.initSlider = function() {
  var that = this;
  var showArrows = ($(this.config.sliderElement).find('li.person').length === 1 ? '' : 
    '<div class="rs-arrows"><a href="#" class="rs-prev"></a><a href="#" class="rs-next"></a></div>');

  $(this.config.sliderElement).refineSlide({
    transition: 'custom',
    customTransitions: [ 'cubeH', 'cubeV'],
    autoPlay: false,
    keyNav: true,
    transitionDuration: 500,
    arrowTemplate: showArrows,
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
      that.commentDom = $(data.comment_partial);
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
  $('.rate-hint, .star, .ratings').hide();

  this.panelsLoader.appendTo(this.panelsContainer).fadeIn();
  this.questionsLoader.appendTo(this.questionsContainer).fadeIn();
  this.storiesLoader.appendTo(this.topStoriesContainer).fadeIn();
};

ListView.prototype.refreshDisplayFor = function(uid) {
  this.panelsData[uid] ? this.paintPanelsSectionFor(uid) : this.retryAndPaintFor('panel', uid);
  this.questionsData[uid] ? this.paintQuestionsSectionFor(uid) : this.retryAndPaintFor('question', uid);
  this.topStoriesData[uid] ? this.paintTopStoriesSectionFor(uid) : this.retryAndPaintFor('story', uid);
  setTimeout(function() {
    $('.rs-next, .rs-prev').removeClass('disable-action');
  }, 1000);
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
  
  if(commonPanels.length > 0) {
    $.each(commonPanels, function(i, cp) {
      var li = $('<li><a></a></li>');
      li.children('a').attr('href', '/panels/' + cp);
      li.children('a').text(that.panelsDictionary[cp]);
      li.appendTo(cLiUl);
    });
    cLiUl.appendTo(commonPanelDom);
  } else {
    commonPanelDom.append($('<span/>').addClass('no-panel').text("No common Panels"));
  }
  if(otherPanels.length > 0) {
    $.each(otherPanels, function(i, rp) {
      var li = $('<li><a></a></li>');
      li.children('a').attr('href', '/panels/' + rp);
      li.children('a').text(that.panelsDictionary[rp]);
      li.appendTo(oLiUl);
    });
    oLiUl.appendTo(otherPanelDom);
  } else {
    otherPanelDom.append($('<span/>').addClass('no-panel').text("No more Panels"));
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
      storyDom.attr('data-story-id', s.id);
      var dhref = storyDom.find('.fb-like').attr('data-href');
      storyDom.find('.fb-like').attr('data-href', dhref + s.id);
      storyDom.addClass('newlyAdded');
      storyDom.find('.story-user img').attr('alt', s.by).attr('href', '/users/' + s.by_id);
      storyDom.find('.story-time a').attr('href', '/story/' + s.id).text($.timeago(s.time));
      storyDom.find('.story-creator a').attr('href', '/users/' + s.by_id).text(s.by);
      storyDom.find('p.story-text').html(s.text);
      storyDom.find('.story-claps').text(s.claps);
      storyDom.find('.story-boos').text(s.boos);
      storyDom.find('.story-comments').text(s.comments);
      storyDom.find('.story-user img').attr('src', s.author_image);
      s.claps > 0     && storyDom.find('.j-show-claps').removeClass('disabled-link');
      s.boos > 0      && storyDom.find('.j-show-boos').removeClass('disabled-link');
      s.comments > 0  && storyDom.find('.j-show-comments, .link-comment').removeClass('disabled-link');
      if(s.comments > 0) {
        $.each(s.comment_bodies, function(i, c) {
          var commentDom = that.commentDom.clone();
          commentDom.find('div.comment-container').attr('data-comment-id', c.comment.id);
          commentDom.find('.comment-user img').attr('src', c.author_photo).attr('alt', c.comment.by);
          commentDom.find('.comment-person-link').attr('href', '/users/' + c.comment.by_id);
          commentDom.find('.comment-creator').text(c.comment.by);
          commentDom.find('.comment-time').text($.timeago(c.comment.created_at));
          if(that.config.sessionUserId === c.comment.by_id) {
            $('<a/>').addClass('close del-comment').attr('href', '#').html('x').appendTo(commentDom.find('.right-container'));
          }
          commentDom.find('.comment-text').html(c.comment.text);
          commentDom.find('.comment-claps').text(c.claps);
          commentDom.find('.comment-boos').text(c.boos);
          c.claps > 0 && commentDom.find('.j-show-comment-claps').removeClass('disabled-link');
          c.boos > 0  && commentDom.find('.j-show-comment-boos').removeClass('disabled-link');
          commentDom.appendTo(storyDom.find('ul.comments'));
        });
      }


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
