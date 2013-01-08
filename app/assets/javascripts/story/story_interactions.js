function StoryHandler(){
  this.showCommentsLink = '';
  this.storySelector = '';
  this.storyDivSelector = '';
  this.bindHandlerForShow = this.bindHandlerForAction = function(){};

  this.LINKS_AND_URLS = [
    { 
      "data": [
        { "link": 'j-show_likes',             "url": 'story/{{sid}}/get/likes' }, 
        { "link": 'j-show_dislikes',          "url": 'story/{{sid}}/get/dislikes' },
        { "link": 'j-show_comments',          "url": 'story/{{sid}}/get/comments' },
        { "link": 'j-show_likes_comment',     "url": 'story/{{sid}}/get/comment/{{number}}/likes' },
        { "link": 'j-show_dislikes_comment',  "url": 'story/{{sid}}/get/comment/{{number}}/dislikes' }
      ],
      "handler": this.bindHandlerForShow
    },
    {
      "data": [
        { "link": 'j-story_like',              "url": 'story/{{sid}}/action/like' },
        { "link": 'j-story_dislike',           "url": 'story/{{sid}}/action/dislike' },
        { "link": 'j-story_comment',           "url": 'story/{{sid}}/action/comment' },
        { "link": 'j-story_like_comment',      "url": 'story/{{sid}}/comment/{{number}}/like' },
        { "link": 'j-story_dislike_comment',   "url": 'story/{{sid}}/comment/{{number}}/dislike' }
      ],
      "handler": this.bindHandlerForAction
    }
  ];
  // this.REFEX_FOR_SHOWING = new RegExp(/j\-show_(\w+)/);
  // this.REGEX_FOR_USER_ACTIONS = new RegExp(/j\-story_(\w+)/);
  this.showMoreCommentsUrl = 'story/{{sid}}/get/more_comments';

  this._init();
}

StoryHandler.prototype._init = function() {
  this.setupSelectors();
};

StoryHandler.prototype.setupSelectors = function() {
  var that = this;
  $.each(this.LINKS_AND_URLS, function(i, object) {
    $.each(object.data, function(i, obj) {
      $(document).on("click", obj.link, function(e) {
        e.preventDefault();
        var storyId = $(this).closest(that.storySelector).attr('data-story-id');
        var commentNumber = '';
        var thisClass = $(this).attr('class');
        if(/comment/.test(thisClass)) {
          commentNumber = $(that.storyDivSelector + ' ' + obj.link).index($(this));
        }
        object.handler(obj.url, storyId, commentNumber);
      });
    });
  });
};

StoryHandler.prototype.bindHandlerForShow = function(url, sid, commentNumber) {
  var getUrl = url.replace(/{{sid}}/, sid).replace(/{{number}}/, commentNumber);
  $.ajax({
    url: getUrl,
    type: "GET",
    success: function(data) {
      that.showInModal(data);
    }, error: function(data) {
      that.showInModal({ "message": "There was some server error. Try again in some time?"});
    }
  });
};

StoryHandler.prototype.bindHandlerForAction = function(url, sid, commentNumber) {
  var postUrl = url.replace(/{{sid}}/, sid).replace(/{{number}}/, commentNumber);
  $.ajax({
    url: postUrl,
    type: "POST",
    success: function(data) {
      that.indicateInPlaceSuccess(data);
    }, error: function(data) {
      that.showInModal({ "message": "There was some server error. Try again in some time?"});
    }
  });
};

StoryHandler.prototype.showInModal = function(data) {
  var x = 10;
};
