function StoryHandler(config){
  this.config = config;
  this.showCommentsLink = '';
  this.storySelector = 'li.story';
  this.storyDivSelector = '';
  var that = this;

  this.LINKS_AND_URLS = [
    { 
      "data": [
        { "link": '.j-show-claps',             "url": '/story/{{sid}}/get?t=claps' }, 
        { "link": '.j-show-boos',              "url": '/story/{{sid}}/get?t=boos' },
        { "link": '.j-show-comment-claps',     "url": '/story/{{sid}}/get/comment/{{number}}/claps' },
        { "link": '.j-show-comment-boos',      "url": '/story/{{sid}}/get/comment/{{number}}/boos' }
      ],
      "handler": this.bindHandlerForShow
    },
    {
      "data": [
        { "link": '.link-like',              "url": '/story/{{sid}}/do?action=clap',                    "update": ".story-claps",   "update_sibling": ".story-boos"     },
        { "link": '.link-dislike',           "url": '/story/{{sid}}/do?action=boo',                     "update": ".story-boos",    "update_sibling": ".story-claps"    },
        { "link": '.submit-comment',         "url": '/story/{{sid}}/do?action=comment',                 "update": ".story-comments"                                     },
        { "link": '.link-like-comment',      "url": '/story/{{sid}}/comment/{{number}}/do?action=clap', "update": ".comment-claps", "update_sibling": ".comment-boos"   },
        { "link": '.link-dislike-comment',   "url": '/story/{{sid}}/comment/{{number}}/do?action=boo',  "update": ".comment-boos",  "update_sibling": ".comment-claps"  }
      ],
      "handler": this.bindHandlerForAction
    }
  ];
  this.showMoreCommentsUrl = '/story/{{sid}}/get/more_comments';

  this._init();
  this.setupSharing();
}

StoryHandler.prototype._init = function() {
  this.setupSelectors();
  $('.header .dropdown-menu').dropdown();
  $('a[data-toggle="tooltip"]').livequery(function() {
    $(this).tooltip();
  });
  $('.header .dropdown-menu li a').on('click', function(e) {
    e.stopPropagation();
  });
  $('.comment-box').live('focusin', function() {
    $(this).animate({'height': '100px'}, 'fast');
    $(this).siblings('.comment-actions').slideDown('fast');
  });
  $('.cancel-comment').live('click', function(e) {
    e.preventDefault();
    $(this).parent('.comment-actions').slideUp('fast');
    $(this).parent().siblings('.comment-box').animate({ 'height': '34px'}, 'fast');
  });

  var that = this;
  $.ajax({
    url: "/panels/dictionary",
    type: "GET",
    dataType: "json",
    success: function(data) {
      that.panelsDictionary = data;
    }, error: function() {
      that.panelsDictionary = {};
    }
  });
  this.setupShowComments();
  this.setupMoreStories();
  this.bindEmbedly();
  this.setupDelete();
  $('a.close_popup').livequery('click', function(e) {
    e.preventDefault();
    $('.people-list').bPopup().close();
  });

  this.shownStories = [];
  $.each($('li.story'), function(i, o) {
    that.shownStories.push($(o).attr('data-story-id'));
  });
};

StoryHandler.prototype.setupSelectors = function() {
  var that = this;
  $.each(this.LINKS_AND_URLS, function(i, object) {
    $.each(object.data, function(i, obj) {
      $(document).on("click", obj.link, function(e) {
        e.preventDefault();
        var storyId = $(this).closest(that.storySelector).attr('data-story-id'), commentId;
        var thisClass = $(this).attr('class');
        if(/comment/.test(thisClass)) {
          commentId = $(this).parents('.comment-container').attr('data-comment-id');
        }
        object.handler.call(that, obj, storyId, commentId);
      });
    });
  });
};

StoryHandler.prototype.bindHandlerForShow = function(obj, sid, commentNumber) {
  var getUrl = obj.url.replace(/{{sid}}/, sid).replace(/{{number}}/, commentNumber), that = this;
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

StoryHandler.prototype.bindHandlerForAction = function(obj, sid, commentNumber) {
  var postUrl = obj.url.replace(/{{sid}}/, sid).replace(/{{number}}/, commentNumber), that = this;
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
      if(data.success) { // Means user is now logged in. 
        that.indicateInPlaceSuccess(sid, obj.update, obj.update_sibling, commentNumber, data.likes_reversed);
        action === "comment" && that.addNewComment(data, sid);
        that.refreshOnUpdate && document.location.reload();
      } else {        
        if(data.ls_required && data.ls_template) { // means user has been asked to login
          that.redo = {
            'action': that.bindHandlerForAction,
            'args': {
              'obj': obj,
              'sid': sid,
              'commentNumber': commentNumber
            }
          };
          that.setupLSFlow(data);
        } else {
          // Means opinion already expressed. Just reload.
          if($('#ls-modal').is(':visible')) {
            document.location.reload();
          } else {
            alert("sorry you have already said that once.");
          }
        }
      }
    }, error: function(data) {
      that.showErrorInModal({ "msg": "There was some server error. Try again in some time?" });
    }
  });
};

StoryHandler.prototype.showInModal = function(data) {
  var personsToShow = JSON.parse(data.persons);
  var defaultPic = '/assets/users/user-small.jpg';
  var div = $('<div/>').append($('<a/>'));
  var li = $('<li></li>').append(div);

  $('div.people-list').remove();
  var outerDiv = $('<div/>').addClass('people-list bpopup').append('<ul/>');
  $('<a/>').attr('href', '#').addClass('close_popup close').text('x').appendTo(outerDiv);

  var ul = outerDiv.find('ul');
  for(var i = 0, len = personsToShow.length; i < len; i++) {
    var l = li.clone();
    var p = personsToShow[i];
    l.find('a').attr('href', '/users/' + p.id).text(p.name);
    $('<img/>').attr('src', p.pic || defaultPic).prependTo(l.find('a'));
    l.appendTo(ul);
  }
  outerDiv.appendTo($('body'));
  outerDiv.bPopup({
    opacity: 0.9,
    followSpeed: 300,
    fadeSpeed: 700,
    position: [500, 'auto'],
    positionStyle: 'absolute',
    easing: 'easeOutBack',
    speed: 450,
    transition: 'slideDown'
  });
};

StoryHandler.prototype.setupLSFlow = function(data) {
  var that = this;
  $(data.ls_template).appendTo($('body'));
  $('#ls-modal').modal({ keyboard: false });
  $('.modal-header a.close').live('click', function(e) {
    e.preventDefault();
    $('#ls-modal').modal('hide');
  });
  this.bindLSValidations();
  this.bindLSActions();
};

StoryHandler.prototype.bindLSActions = function() {
  var that = this;
  $('#login_form')
  .live("ajax:beforeSend", function(evt, xhr, settings) {
    $('div.login-error', this).remove();
  })
  .live("ajax:success", function(evt, data, status, xhr) {
    var form = $(this);
    form.find('textarea,input[type="text"],input[type="password"]').val("");
    if(data.success) {
      that.refreshOnUpdate = true;
      that.redoAction();
    } else {
      var error = $('<div/>').addClass('login-error')
        .html("Invalid email or password. <br/>Use the 'Forgot Password?' link if you don't remember password");
      error.insertAfter($(form).find('h3'));
    }
  })
  .live("ajax:error", function(evt, xhr, settings, error) {
    alert('error');
  });


  $('#signup_form')
  .live("ajax:beforeSend", function(evt, xhr, settings) {
    $('div.login-error', this).remove();
  })
  .live("ajax:success", function(evt, data, status, xhr) {
    var form = $(this);
    form.find('input[type="text"], input[type="password"], input[type="checkbox"]').val("");
    if(data.success) {
      that.refreshOnUpdate = true;
      that.redoAction();
    } else {
      var error = $('<div/>').addClass('login-error').html(data.message).insertAfter($(form).find('h3'));
    }
  });
};

StoryHandler.prototype.redoAction = function() {
  var handler = this.redo.action;
  var args = this.redo.args;
  handler.call(this, args.obj, args.sid, args.commentNumber);
};

StoryHandler.prototype.bindLSValidations = function() {
  $('.s-container form').validate({
    submitHandler: function(form) {
      $(form).ajaxSubmit();
    }, rules: {
      name: {
        required: true,
        minlength: 4
      },
      email: {
        required: true,
        email: true
      },
      conditions: "required",
      password: {
        required: true,
        minlength: 5
      },
      password_confirmation: {
        required: true,
        equalTo: '.s-container form input[name=password]'
      }
    },
    messages: {
      name: {
        required: "We need a name to know you",
        minlength: "At least 4 characters is a normal name"
      },
      email: {
        required: "This is where verification mail will be sent",
        email: "This should be like name@domain.com"
      },
      password: {
        required: "This is for your own safety",
        minlength: "Give a strong password, at least 5 letters strong"
      },
      password_confirmation: {
        required: "Confirm password please",
        equalTo: "Passwords must match"
      },
      conditions: "Accept policies please"
    },
    errorLabelContainer: ".s-container #validation-errors"
  });

};

StoryHandler.prototype.indicateInPlaceSuccess = function(sid, selector, siblingSelector, commentNumber, likes_reversed) {
  var story = $(this.storySelector).filter('[data-story-id=' + sid + ']'), toUpdate;
  if(likes_reversed) {
    var toAdd, toSub;
    if(selector.indexOf('comment-') !== -1) {
      toAdd = story.find('.comment-container[data-comment-id=' + commentNumber + ']').find(selector);
      toSub = story.find('.comment-container[data-comment-id=' + commentNumber + ']').find(siblingSelector);
    } else {
      toAdd = story.find(selector), toSub = story.find(siblingSelector);
    }
    var beforeAddText = parseInt(toAdd.text(), 10);
    if(beforeAddText === 0) {
      toAdd.parent().removeClass('disabled-link');
    }
    toAdd.text(beforeAddText + 1);

    toSub.text(parseInt(toSub.text(), 10) - 1);
    var afterSubText = parseInt(toSub.text(), 10);
    if(afterSubText === 0) {
      toSub.parent().addClass('disabled-link');
    }
  } else {
    if(selector.indexOf('comment-') !== -1) {
      toUpdate = story.find('.comment-container[data-comment-id=' + commentNumber + ']').find(selector);
    } else {
      toUpdate = story.find(selector);
    }
    var beforeUpdateText = parseInt(toUpdate.text(), 10);
    if(beforeUpdateText === 0) {
      toUpdate.parent().removeClass('disabled-link');
    }
    toUpdate.text(beforeUpdateText + 1);
  }
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
    var closestComments = $(this).parents('.like-area').siblings('.comment-area').children('ul.comments');
    if(closestComments.children('li:visible').length === 3) {
      closestComments.children('li').remove();
    } else if(closestComments.is(':visible')) {
      closestComments.slideUp('fast');
      return;
    }
    var story = $(this).parents('li.story');
    var sid = story.attr('data-story-id');
    var getCommentsUrl = "/story/" + sid + "/get?t=comments";
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
    obj.comment.claps = obj.claps;
    obj.comment.boos = obj.boos;
    that.addCommentToDisplay(ul, commentTemplate, obj.comment);
  });
};

StoryHandler.prototype.addCommentToDisplay = function(ul, template, comment) {
  var newComment = $(template);

  newComment.find('div.comment-container').attr('data-comment-id', comment.id);
  newComment.find('.comment-user-img').attr('alt', comment.by).attr('src', comment.photo_url);
  newComment.find('.comment-creator').text(comment.by);
  newComment.find('.comment-time').text($.timeago(comment.created_at));
  newComment.find('.comment-text').html(comment.text);
  newComment.find('.comment-person-link').attr('href', '/users/' + comment.by_id)
  .attr('data-toggle', 'tooltip').attr('title', 'See full profile');
  newComment.find('.comment-claps').text(comment.claps || 0);
  newComment.find('.comment-boos').text(comment.boos || 0);
  if(this.config.forUserId === comment.by_id) {
    newComment.find('.right-container').append(
      $('<a/>').attr('href', '#').addClass('close del-comment')
      .attr('data-toggle', 'tooltip').attr('title', 'Delete comment').text('x')
    );
  }
  
  newComment.hide().delay(500).appendTo(ul).fadeIn('slow'); // add animation
};

StoryHandler.prototype.setupMoreStories = function() {
  var that = this;
  $('a.more-stories').on('click', function(e) {
    e.preventDefault();
    var moreClicker = $(this);
    moreClicker.find('img').show();
    var storiesShown = $('li.story').length;
    var linkForMoreStories = '/stories/more/' + that.config.forUserId + ( that.config.dashboard ? '/for_dashboard/' : '/' ) + storiesShown;
    
    $.ajax({
      url: linkForMoreStories,
      type: "GET",
      dataType: "json",
      success: function(data) {
        var sDoms = [];
        for(var i = 0, len = data.stories.length; i < len; i++ ) {
          var storyDom = $(data.story_partial).clone();
          var s = data.stories[i];

          // Hack to avoid duplicate stories till something is done at the back end
          if($.inArray('' + s.id, that.shownStories) !== -1) {
            that.shownStories.push(s.id);
            storyDom.addClass('newlyAdded');
            storyDom.attr('data-story-id', s.id);
            storyDom.find('.story-user img').attr('alt', s.by).attr('src', s.author_image);
            storyDom.find('.story-time a').attr('href', '/story/' + s.id).text($.timeago(s.time));
            storyDom.find('.story-creator a').text(s.by).attr('href', '/users/' + s.by_id);
            storyDom.find('p.story-text').html(s.text);
            storyDom.find('.story-claps').text(s.claps);
            storyDom.find('.story-boos').text(s.boos);
            storyDom.find('.story-comments').text(s.comments);
            if(s.claps !== 0) {
              storyDom.find('.j-show-claps').removeClass('disabled-link');
            }
            if(s.boos !== 0) {
              storyDom.find('.j-show-boos').removeClass('disabled-link');
            }
            if(s.comments !== 0) {
              storyDom.find('.j-show-comments, .link-comment').removeClass('disabled-link');
            }
            if(s.by_id === that.config.forUserId + '') {
              $('<a/>').attr('href', '#').attr('class', 'del-story close').attr('title', 'Delete Story')
              .attr('data-story-id', s.id).attr('data-toggle', 'tooltip').attr('data-placement', 'bottom')
              .text($('<div/>').html('&#215;').text()).appendTo(storyDom.find('.story-time'));
            }

            var panelsUl = storyDom.find('ul.story-tags');

            $.each(s.panels, function(i, p) {
              var li = $('<li/>');
              $('<a>').attr('href', '/panels/' + p).text(that.panelsDictionary[p]).appendTo(li);
              li.appendTo(panelsUl);
            });
            sDoms.push(storyDom);
          }
        } // for
        
        moreClicker.find('img').hide();
        var storiesUl = $(that.config.storiesContainer);
        $.each(sDoms, function(i, s) {
          setTimeout(function() {
            s.appendTo(storiesUl).hide();
            s.slideDown('slow');
          }, 100);
        });
        that.bindEmbedly();
        if(data.fallback_mode === 0 || data.fallback_mode === 1) {
          $('a.more-stories').hide();
          $('<span/>').addClass('usingFallback').text('No more stories to show').appendTo($('a.more-stories').parent());
        }
      }, error: function(data) {
        moreClicker.find('img').hide();
      }
    });
  });
};

StoryHandler.prototype.bindEmbedly = function() {
  $('li.story p.story-text').livequery(function() {
    $('li.story p.story-text:not(.embedded)').embedly({
      maxWidth: 400,
      wmode: 'transparent',
      method: 'after',
      chars: 250,
      key:'1c33c83e4cf34598a4dc7f96d77b5b06'    
    }).addClass('embedded');
  });
  $('li.story div.embed a').livequery(function() {
    $(this).attr('target', '_blank');
  });
};

StoryHandler.prototype.setupDelete = function() {
  var that = this;
  $('li.story a.del-story').livequery('click', function(e) {
    e.preventDefault();
    var ok = confirm("Are you sure you want to delete this story?");
    if(ok) {
      var clickedStory = $(this).parents('li.story');
      var delUrl = "/story/" + $(this).attr('data-story-id') + "/delete";
      $.ajax({
        url: delUrl,
        type: "POST",
        success: function(data) {
          clickedStory.fadeOut('slow');
          setTimeout(function() {
            clickedStory.remove();
          }, 500);
        }
      });
    }
  });

  $('.del-comment').livequery('click', function(e) {
    e.preventDefault();
    var comment = $(this).parents('div.comment-container');
    var delUrl = "/story/" + $(this).parents('li.story').attr('data-story-id') + "/comment/" 
      + comment.attr('data-comment-id') + "/do";
    $.ajax({
      url: delUrl,
      type: "POST",
      data: { "work": "delete"},
      success: function(data) {
        comment_count_dom = comment.parents('.comment-area').siblings('.like-area').find('.story-comments');
        comment_count_dom.text(parseInt(comment_count_dom.text(), 10) - 1);
        comment.parent('li').slideUp('slow');
        setTimeout(function() {
          comment.parent('li').remove();
        }, 500);
      }
    });
  });
};

StoryHandler.prototype.setupSharing = function() {
  if(!this.sharingInitHappened) {
    (function(d, s, id) {
      var js, fjs = d.getElementsByTagName(s)[0];
      if (d.getElementById(id)) return;
      js = d.createElement(s); js.id = id;
      js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
      fjs.parentNode.insertBefore(js, fjs);
    }(document, 'script', 'facebook-jssdk'));
    this.sharingInitHappened = true;
  }

  $('li.story.newlyAdded').livequery(function() {
    try {
      FB.XFBML.parse();
    } catch(ex){}        
  });
  $('li.story').livequery(function() {
    $('.social-share', this).pin({ containerSelector: this});
  });
};

