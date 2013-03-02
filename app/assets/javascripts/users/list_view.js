function ListView(config) {
  this.config = config;
  this._getDomPartials();
  this._initStructures();
  this.getAllData();
  this.initSlider();
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
  if(this.constructedPanelDom && this.constructedPanelDom[uid] ) {
    this.panelsLoader.hide();
    this.constructedPanelDom[uid].appendTo(this.panelsContainer);
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
  if(!this.constructedPanelDom){
    this.constructedPanelDom = {};
  }
  this.constructedPanelDom[uid] = domObj;
};

ListView.prototype.paintQuestionsSectionFor = function(uid) {
  var data = this.questionsData[uid], that = this, uname = this.userInfo[uid];
  this.questionsLoader.hide();

  if(data.answers.length === 0) {
    $('<h3/>').addClass('no-content').text("Sorry no questions found for " + uname).appendTo(this.questionsContainer);
  } else {
    $.each(data.answers, function(i, an) {
      var questionDom = that.questionDom.clone();
      questionDom.find('.q-text').text(an.q);
      questionDom.find('.a-text').text(an.a);
      questionDom.appendTo(that.questionsContainer);
    });
  }
};

ListView.prototype.paintTopStoriesSectionFor = function(uid) {
  var data = this.topStoriesData[uid], that = this, uname = this.userInfo[uid];
  this.storiesLoader.hide();

  if(data.stories.length === 0) {
    $('<h3/>').addClass('no-content').text("Sorry no stories found for " + uname).appendTo(this.topStoriesContainer);    
  } else {
    $.each(data.stories, function(i, s) {
      var storyDom = that.storyDom.clone();
      storyDom.find('.story-creator').text(s.by);
      storyDom.find('.story-time').text(s.when);
      storyDom.find('.story-text').text(s.text);
      storyDom.find('.story-claps').text(s.clap_count);
      storyDom.find('.story-boos').text(s.boo_count);
      storyDom.find('.story-comments').text(s.comment_count);
      
      storyDom.appendTo(that.topStoriesContainer);
    });
  }
};
