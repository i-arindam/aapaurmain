function ListView(config) {
  this.config = config;
  this._getDomPartials();
  this._initStructures();
  this.getAllData();
  this.bindDisplayChange();
}

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
    }, error: function(data) {
      setTimeout(function() {
        that._getDomPartials();
      }, 50);
    }
  });
};

ListView.prototype._initStructures = function() {  
  this.activeUserId = this.config.sessionUserId;
  this.firstUserId = this.config.userIds[0];
  
  this.panelsContainer = $('ul.panels');
  this.topStoriesContainer = $('ul.story-container');
  this.questionsContainer = $('ul.questions');

  this.PanelsLoader = $('div.panels-loader');
  this.storiesLoader = $('div.top-stories-loader');
  this.questionsLoader = $('div.questions-loader');

  this.PanelsData = this.questionsData = this.topStoriesData = {};

  this.OBJECTS_HASH = {
    'panel': {
      'url': '/panels/all/{{sessionUserId}}/{{forUserId}}',
      'result': this.PanelsData,
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

ListView.prototype.bindDisplayChange = function() {
  var that = this;
  $('div.leftNav').click(function(e) {
    setTimeout(function() {
      that.clearContentAndShowLoader();
      that.refreshDisplayFor(10);
    }, 100);
  });
};

ListView.prototype.clearContentAndShowLoader = function() {
  this.panelsContainer.remove();
  this.questionsContainer.remove();
  this.topStoriesContainer.children('li.story').remove();

  this.PanelsLoader.appendTo(this.panelsContainer).fadeIn();
  this.questionsLoader.appendTo(this.questionsContainer).fadeIn();
  this.storiesLoader.appendTo(this.topStoriesContainer).fadeIn();
};

ListView.prototype.refreshDisplayFor = function(uid) {
  this.PanelsData.uid ? this.paintPanelsSectionFor(uid) : this.retryAndPaintFor('panel', uid);
  this.questionsData.uid ? this.paintQuestionsSectionFor(uid) : this.retryAndPaintFor('question', uid);
  this.topStoriesData.uid ? this.paintTopStoriesSectionFor(uid) : this.retryAndPaintFor('story', uid);
};

ListView.prototype.retryAndPaintFor = function(obj, uid) {
  this.getDataFor(obj, uid, true);
};

ListView.prototype.paintPanelsSectionFor = function(uid) {
  var data = this.questionsData[uid], that = this, commonPanelLi, remainingPanelLi;
  var commonPanels = data.commonPanels.join(", "), otherPanels = data.remainingPanels.join(", ");
  this.PanelsLoader.fadeOut();

  var panelDom = that.panelDom.clone();
  panelDom.find('.shared-by span.other-user').text(that.usersData[uid].name);
  panelDom.find('.common-panels').text(commonPanels);
  panelDom.find('.other-panels').text(otherPanels);

  panelDom.appendTo(that.panelsContainer);
};

ListView.prototype.paintQuestionsSectionFor = function(uid) {
  var data = this.questionsData[uid], that = this;
  this.questionsLoader.fadeOut();

  var questionDom = this.questionDom.find('li.question');
  $.each(data.answers, function(i, an) {
    var qLi = questionDom.clone();
    qLi.find('.q-text').text(an.q);
    qLi.find('.a-text').text(an.a);
    qLi.appendTo(that.questionsContainer);
  });
};

ListView.prototype.paintTopStoriesSectionFor = function(uid) {
  var data = this.topStoriesData[uid], that = this;
  this.storiesLoader.fadeOut();

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
};
