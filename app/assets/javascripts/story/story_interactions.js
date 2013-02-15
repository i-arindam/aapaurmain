function StoryHandler(){
  this.showCommentsLink = '';
  this.storySelector = 'li.story';
  this.storyDivSelector = '';
  var that = this;

  this.LINKS_AND_URLS = [
    { 
      "data": [
        { "link": '.j-show-claps',             "url": 'story/{{sid}}/get?t=claps' }, 
        { "link": '.j-show-boos',              "url": 'story/{{sid}}/get?t=boos' },
        { "link": '.j-show-comments',          "url": 'story/{{sid}}/get?t=comments' },
        { "link": '.j-show-comment-claps',     "url": 'story/{{sid}}/get/comment/{{number}}/likes' },
        { "link": '.j-show-comment-boos',      "url": 'story/{{sid}}/get/comment/{{number}}/dislikes' }
      ],
      "handler": this.bindHandlerForShow
    },
    {
      "data": [
        { "link": '.link-like',              "url": 'story/{{sid}}/do?action=clap',             "update": ".story-claps" },
        { "link": '.link-dislike',           "url": 'story/{{sid}}/do?action=boo',              "update": ".story-boos" },
        { "link": '.submit-comment',         "url": 'story/{{sid}}/do?action=comment',          "update": ".story-comments" },
        { "link": '.link-like-comment',      "url": 'story/{{sid}}/comment/{{number}}/like',    "update": ".comment-claps" },
        { "link": '.link-dislike-comment',   "url": 'story/{{sid}}/comment/{{number}}/dislike', "update": ".comment-boos" }
      ],
      "handler": this.bindHandlerForAction
    }
  ];
  this.showMoreCommentsUrl = 'story/{{sid}}/get/more_comments';

  this._init();
}

StoryHandler.prototype._init = function() {
  this.setupSelectors();
  $('.comment-box').live('focusin', function() {
    $(this).animate({'height': '100px'}, 'fast');
    $(this).siblings('.submit-comment').show();
  });
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
        object.handler.call(that, obj.url, storyId, obj.update, commentNumber);
      });
    });
  });
};

StoryHandler.prototype.bindHandlerForShow = function(url, sid, commentNumber) {
  var getUrl = url.replace(/{{sid}}/, sid).replace(/{{number}}/, commentNumber), that = this;
  $.ajax({
    url: getUrl,
    type: "GET",
    dataType: "json",
    success: function(data) {
      that.showInModal(data);
    }, error: function(data) {
      that.showErrorInModal({ "msg": "There was some server error. Try again in some time?"});
    }
  });
};

StoryHandler.prototype.bindHandlerForAction = function(url, sid, selector, commentNumber) {
  var postUrl = url.replace(/{{sid}}/, sid).replace(/{{number}}/, commentNumber), that = this;
  var action = postUrl.match(/do\?action=(\w+)/)[1];
  var postData = { 'work' : action };
  if(action === "comment") {
    postData['text'] = $('li.story[data-story-id=' + sid + ']').find('.comment-box').val();
  }
  $.ajax({
    url: postUrl,
    type: "POST",
    data: postData,
    dataType: "json",
    success: function(data) {
      if(data.success) { 
        that.indicateInPlaceSuccess(sid, selector, commentNumber);
        action === "comment" && that.addNewComment(data, sid);
      } else {
        that.showErrorInModal({ "msg": "You have already expressed your opinion! Sorry can't do it again" });
      }
    }, error: function(data) {
      that.showErrorInModal({ "msg": "There was some server error. Try again in some time?" });
    }
  });
};

StoryHandler.prototype.showInModal = function(data) {
  var personsToShow = JSON.parse(data.persons);
  var deafultPic = '/images/users/user-small.jpg';

};

StoryHandler.prototype.indicateInPlaceSuccess = function(sid, selector, commentNumber) {
  var story = $(this.storySelector).filter('[data-story-id=' + sid + ']');
  var toUpdate = story.find(selector);
  toUpdate.text(parseInt(toUpdate.text(), 10) + 1);
};

StoryHandler.prototype.showErrorInModal = function(data) {
  alert(data.msg);
};

StoryHandler.prototype.addNewComment = function(data, sid) {
  var story = $(this.storySelector).filter('[data-story-id=' + sid + ']');
  var commentBox = story.find('.comment-box');
  commentBox.val('');
  var commentsUl = story.find('ul.comments');
  var newComment = $(data.comment_template);
  newComment.find('.comment-claps').text(0);
  newComment.find('.comment-boos').text(0);
  newComment.appendTo(commentsUl);
  commentsUl.removeClass('hide');
};
