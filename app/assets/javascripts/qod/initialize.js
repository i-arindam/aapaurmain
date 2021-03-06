function QOD(qodId, sessionUserId) {
  this.qodId = qodId;
  this.sessionUserId = sessionUserId;
  this._init();
}

QOD.prototype._init = function() {
  var that = this;
  this.offset = 0;
  this.questionBlock = $('.j-qod_container .j-qod_question');
  this.initialRenderUrl = '/qod/' + this.qodId;
  this._getInitialMessages();

  this.qodWrapper = $('.qodWrapper');
  this.qodLink = $('.j-show_discussion');
  this.signupWrapper = $('.signup');
  this.signupLink = $('.j-show_signup');

  this.signupLink.click(function(e) {
    e.preventDefault();
    that.qodWrapper.fadeOut();
    that.signupWrapper.fadeIn();
  });
  this.qodLink.click(function(e) {
    e.preventDefault();
    that.signupWrapper.fadeOut();
    that.qodWrapper.fadeIn();
    // that.signupLink.fadeIn();
  });

  $('form.j-qod_answer_form').submit(function() {
    that._SubmitHandler();
    return false;
  });

  $('.qodContainer').scroll(function() {
    that._scrollHandler.apply(that, [this]);
  });

};

QOD.prototype._getInitialMessages = function() {
  var that = this;
  $.ajax({
    url: this.initialRenderUrl,
    type: 'GET',
    dataType: 'json',
    success: function(data) {
      if(data.success) {
        that._addAndShow(data);
      }
      that.offset += 10;
    }, error: function(data) {
    }
  });
};

QOD.prototype._getMoreMessages = function() {
  var that = this;
  $.ajax({
    url: this.initialRenderUrl + "?offset=" + this.offset,
    type: 'GET',
    dataType: 'json',
    success: function(data) {
      if(data.success) {
        that._addMoreAnswers(data);
      }

    }, error: function(data) {
    }
  });
};

QOD.prototype._addMoreAnswers = function(data) {
  var answer = data.payload.answers.user_answers;
  var answersCount = data.payload.answers.size;
  var that = this;

  if(answersCount > 0) {
    var answersUl = $('.j-qod_answers');
    $.each(answer, function(i, obj) {
      var answerLi = that._formAnswerDom(obj);
      answerLi.appendTo(answersUl);
    });
    that.offset += 10;
  }
};

QOD.prototype._addAndShow = function(data) {
  this.question = data.payload.question;
  this.answer = data.payload.answers.user_answers;
  this.answersCount = data.payload.answers.size;

  /* Write question to DOM */
  var when = moment(new Date(this.question.when)); //TODO Check in IE once
  this.questionBlock.find('.question').text(this.question.text);
  this.questionBlock.find('.when').text(when.format('h:mm a'));
  this.questionBlock.find('.by').text(this.question.by);
  if(this.question.likes > 0) {
    this.questionBlock.find('.likes').text(this.question.likes);
  }
  if(this.question.dislikes > 0) {
    this.questionBlock.find('.dislikes').text(this.question.dislikes);
  }

  var answersUl = $('<ul />').addClass('qodAnswers j-qod_answers');
  
  /* Write answers to DOM */
  if(this.answersCount > 0) {
    $('<div />').addClass('answerHeading').text('The People have spoken: ').appendTo('.j-qod_container');
    var that = this;

    $.each(this.answer, function(i, obj) {
      var answerLi = that._formAnswerDom(obj);
      answerLi.appendTo(answersUl);
    });
  }

  $('.j-qod_container .j-loader').fadeToggle(2000);
  this.questionBlock.show();
  answersUl.appendTo($('.j-qod_container'));

  var that = this;
  $('.qodForm textarea').simplyCountable({
    counter: '.qodForm .counter',
    countType: 'characters',
    maxCount: 160,
    onOverCount: function(count, countable, counter) {
      $('.qodForm input').addClass('disabled').attr('disabled', 'disabled');
    },
    onSafeCount: function(count, countable, counter) {
      $('.qodForm input').removeClass('disabled').removeAttr('disabled');
    }
  });
};

QOD.prototype._SubmitHandler = function() {
  var answer = $('.j-qod_answer_form textarea').val();
  $('.j-qod_answer_form textarea').val('');
  $('.charsLeft .counter').text('160');

  var that = this;
  $.ajax({
    url: '/qod/' + this.qodId + '/answers/new',
    type: 'POST',
    data: {
      'text' : answer,
      'creator_id' : that.sessionUserId
    },
    dataType: 'json',
    success: function(data) {
      if(!data.success) {
        alert(data.payload);
      } else if (data.success) {
        var answerLi = that._formAnswerDom(data.payload.answer);
        $(answerLi).hide().prependTo($('ul.j-qod_answers')).slideDown('slow');
      }
    }, error: function(data) {
      alert("Sorry answer could not be posted due to some error. Try again?");
    }
  });
};

QOD.prototype._scrollHandler = function(ele) {
  if($(ele).scrollTop() >= $(ele)[0].scrollHeight - $(ele).innerHeight()) {
    this._getMoreMessages();
  } else {
  }
};

QOD.prototype._formAnswerDom = function(obj) {
  var answerLi = $('<li />').addClass('qodAnswer j-qod_answer');
  $('<span />').addClass('answerText j-answer_text').text(obj.text).appendTo(answerLi);
  $('<span />').addClass('answerBy j-answer_by').text(obj.by)
    .appendTo($('<a />').attr('href', '/users/' + obj.by_id).attr('rel', 'nofollow')
      .addClass('answerBy j-answer_by').appendTo(answerLi));
  var answerTime = moment(new Date(obj.when));
  $('<span />').addClass('answerTime j-answer_time').text(answerTime.format('h:mm a')).appendTo(answerLi);
  return answerLi;
}
