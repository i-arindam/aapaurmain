function ListView(config) {
  this.config = config;
  this._initStructures();
  this.getAllData();
  this.bindDisplayChange();
}

ListView.prototype._initStructures = function() {  
  this.activeUserId = this.config.sessionUserId;
  this.firstUserId = this.config.firstUserId;
  
  this.commonBoardsContainer = $('ul.common-boards');
  this.remainingBoardsContainer = $('ul.remaining-boards');
  this.topStoriesContainer = $('ul.top-stories');
  this.questionsContainer = $('ul.questions');

  this.boardsLoader = $('.boardsLoader');
  this.storiesLoader = $('.storiesLoader');
  this.questionsLoader = $('.questionsLoader');

  this.storyDom = this.config.storyDom;

  this.boardsData = this.questionsData = this.topStoriesData = {};

  this.OBJECTS_HASH = {
    'board': {
      'url': '/boards/all/{{sessionUserId}}/{{forUserId}}',
      'result': this.boardsData,
      'callback': this.paintBoardsSectionFor
    },
    'question': {
      'url': '/questions/all/{{forUserId}}',
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
        that.getDataFor('board', uid);
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
    success: function(data) {
      resultSet.uid = data;
      if(useCallback) {
        that.trigger(callbackHandler, uid);
      }
    }, error: function(data) {
      resultSet.uid = nil;
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
  this.commonBoardsContainer.children('li.common-board').remove();
  this.remainingBoardsContainer.children('li.remaining-board').remove();
  this.questionsContainer.children('li.question').remove();
  this.topStoriesContainer.children('li.top-story').remove();

  this.boardsLoader.appendTo(this.commonBoardsContainer).show();
  this.questionsLoader.appendTo(this.questionsContainer).show();
  this.storiesLoader.appendTo(this.topStoriesContainer).show();
};

ListView.prototype.refreshDisplayFor = function(uid) {
  this.boardsData.uid ? this.paintBoardsSectionFor(uid) : this.retryAndPaintFor('board', uid);
  this.questionsData.uid ? this.paintQuestionsSectionFor(uid) : this.retryAndPaintFor('question', uid);
  this.topStoriesData.uid ? this.paintTopStoriesSectionFor(uid) : this.retryAndPaintFor('story', uid);
};

ListView.prototype.retryAndPaintFor = function(obj, uid) {
  this.getDataFor(obj, uid, true);
};

ListView.prototype.paintBoardsSectionFor = function(uid) {
  var data = this.questionsData.uid, that = this, commonBoardLi, remainingBoardLi;
  this.boardsLoader.fadeOut();

  $.each(data.commonBoards, function(i, cb) {
    commonBoardLi = $('<li/>').addClass('common-board');
    $('<a/>').addClass('board-link').appendTo(commonBoardLi);
    commonBoardLi.appendTo(that.commonBoardsContainer);
  });

  $.each(data.remainingBoards, function(i, rb) {
    remainingBoardLi = $('<li/>').addClass('remaining-board');
    $('<a/>').addClass('board-link').appendTo(remainingBoardLi);
    remainingBoardLi.appendTo(that.remainingBoardsContainer);
  });
};

ListView.prototype.paintQuestionsSectionFor = function(uid) {
  var data = this.questionsData.uid, questionLi, that = this;
  this.questionsLoader.fadeOut();

  $.each(data.questions, function(i, q) {
    questionLi = $('<li/>').addClass('question');
    $('<span>').addClass('question-body').text(q.question).appendTo(questionLi);
    $('<span>').addClass('answer-body').text(q.answer).appendTo(questionLi);
    questionLi.appendTo(that.questionsContainer);
  });
};

ListView.prototype.paintTopStoriesSectionFor = function(uid) {
  var data = this.topStoriesData.uid, that = this;
  var storyDiv, storyContentDiv;
  this.storiesLoader.fadeOut();

  $.each(data.stories, function(i, s) {
    storyDom.find('span.author-name').text(s.by);
    storyDom.find('span.story-time').text(s.when);
    storyDom.find('div.story-content').text(s.text);
    storyDom.find('span.clap-count').text(s.clap_count);
    storyDom.find('span.boo-count').text(s.boo_count);
    storyDom.find('span.comment-count').text(s.comment_count);
    
    storyLi = $('<li/>').addClass('top-story');
    storyDom.wrap(storyLi);
    storyLi.appendTo(that.topStoriesContainer);
  });
};
