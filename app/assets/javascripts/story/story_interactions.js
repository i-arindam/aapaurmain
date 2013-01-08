function StoryHandler(){
  this.showCommentsLink = $();
  // this.showLikesLink = $(); // @TODO: make these just selector string
  // this.showDislikesLink = $();
  // this.showLikesOnCommentLink = $();
  // this.showDislikesOnCommentLink = $();
  this.storySelector = $();

  this.LINKS_AND_URLS_FOR_SHOWING = {
    "likes"           : { "link": 'j-show_likes',             "url": 'story/{{sid}}/get/likes' }, 
    "dislikes"        : { "link": 'j-show_dislikes',          "url": 'story/{{sid}}/get/dislikes' },
    "likes_comment"   : { "link": 'j-show_likes_comment',     "url": 'story/{{sid}}/get/comment/{{number}}/like' },
    "dislikes_comment": { "link": 'j-show_dislikes_comment',  "url": 'story/{{sid}}/get/comment/{{number}}/dislike' }
  };
  this.REFEX_FOR_SHOWING = new RegExp(/j\-show(\w+)/);

  this.LINKS_AND_URLS_FOR_USER_ACTIONS = {
    "like"           : { "link": 'j-story_like',              "url" : 'story/{{sid}}/action/like' },
    "dislike"        : { "link": 'j-story_dislike',           "url": 'story/{{sid}}/action/dislike' },
    "like_comment"   : { "link": 'j-story_like_comment',      "url": 'story/{{sid}}/comment/{{number}}/like' },
    "dislike_comment": { "link": 'j-story_dislike_comment',   "url": 'story/{{sid}}/comment/{{number}}/dislike' }
  }; 
  this.REGEX_FOR_USER_ACTIONS = new RegExp(/j\-story_(\w+)/);

  // this.showLikesUrl = 'story/{{sid}}/get/likes';
  // this.showDislikesUrl = 'story/{{sid}}/get/dislikes';
  // this.showLikesCommentUrl = 'story/{{sid}}/get/comment/{{number}}/like';
  // this.showDislikesCommentUrl = 'story/{{sid}}/get/comment/{{number}}/dislike'
  // this.likeUrl = 'story/{{sid}}/action/like';
  // this.dislikeUrl = 'story/{{sid}}/action/dislike';
  // this.likeCommentUrl = 'story/{{sid}}/comment/{{number}}/like';
  // this.dislikeCommentUrl = 'story/{{sid}}/comment/{{number}}/dislike';

  this.showCommentsUrl = 'story/{{sid}}/get/comments';
  this.showMoreCommentsUrl = 'story/{{sid}}/get/more_comments';
  this.commentUrl = 'story/{{sid}}/action/comment';

  this._init();
}

StoryHandler.prototype._init = function() {
  this.setupSelectors();
  this.handlersForShowingComments();
  this.handlersForShowingNames();
  this.handlersForUserActions();

  // Handlers for showing stuff.
  // this.showLikesHandler();
  // this.showDislikesHandler();
  // this.showLikesOnCommentHandler();
  // this.showDislikesOnCommentHandler();
  // this.showCommentsHandler();

  // Handlers for actions
  // this.likeHandler();
  // this.dislikeHandler();
  // this.likeCommentHandler();
  // this.dislikeCommentHandler();
  this.commentSubmitHandler();
};

StoryHandler.prototype.setupSelectors = function() {
  var that = this;
  this.SELECTORS_FOR_SHOWING_NAMES = [];
  $.each(this.LINKS_AND_URLS_FOR_SHOWING, function(i, obj) {
    $(document).on("click", obj.link, function(e) {
      e.preventDefault();
      var storyId = $(this).closest(that.storySelector).attr('data-story-id');
      that.bindHandlerForShow(obj.url, storyId);
    });
  });
};

StoryHandler.prototype.bindHandlerForShow = function(url, sid) {
  var getUrl = url.replace(/{{sid}}/, sid);
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

StoryHandler.prototype.handlersForShowingComments = function() {

};


StoryHandler.prototype.showInModal = function(data) {
  var x = 10;
};
