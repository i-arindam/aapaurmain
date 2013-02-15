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
        // { "link": '.j-show-comments, .link-comment',          "url": 'story/{{sid}}/get/comments' },
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
    $(this).siblings('.comment-actions').slideDown('fast');
  });
  $('.cancel-comment').live('click', function(e) {
    e.preventDefault();
    $(this).parent('.comment-actions').slideUp('fast');
    $(this).parent().siblings('.comment-box').animate({ 'height': '34px'}, 'fast');
  });
  this.setupShowComments();
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
  var story = $(this.storySelector).filter('[data-story-id=' + sid + ']'), commentBox = story.find('.comment-box');
  var commentsUl = story.find('ul.comments');
  commentBox.val('');
  commentsUl.show();
  this.addCommentToDisplay(commentsUl, data.template, data.comment);
};

StoryHandler.prototype.setupShowComments = function() {
  var that = this;
  $('.j-show-comments, .link-comment').live('click', function(e) {
    e.preventDefault();
    var story = $(this).parents('li.story');
    var sid = story.attr('data-story-id');
    var getCommentsUrl = "story/" + sid + "/get?t=comments";
    $.ajax({
      url: getCommentsUrl,
      type: "GET",
      dataType: "json",
      data: { 'start': 0, 'end': 9 },
      success: function(data) {
        that.showReceivedComments(data, sid);
      }, error: function(data) {
        that.showErrorInModal({ 'msg': "Couldn't fetch the comments. Try again? "});
      }
    });
  });
};

StoryHandler.prototype.showReceivedComments = function(data, sid) {
  var commentsToShow = data.comments, commentTemplate = data.template, that = this;
  var story = $(this.storySelector).filter('[data-story-id=' + sid + ']');
  var ul = story.find('ul.comments');
  ul.slideDown('fast');
  ul.children('li').remove();
  $.each(commentsToShow, function(i, obj) {
    that.addCommentToDisplay(ul, commentTemplate, obj);
  });
};

StoryHandler.prototype.addCommentToDisplay = function(ul, template, comment) {
  var newComment = $(template);

  newComment.find('.comment-user-img').attr('alt', comment.by);
  newComment.find('.comment-creator').text(comment.by);
  newComment.find('.comment-time').text(comment.when + 'ago');
  newComment.find('.comment-text').text(comment.text);
  newComment.find('.comment-claps').text(comment.claps || 0);
  newComment.find('.comment-boos').text(comment.boos || 0);
  
  newComment.hide().appendTo(ul).show('fast'); // add animation
};
