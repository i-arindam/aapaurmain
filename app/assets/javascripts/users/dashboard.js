function Dashboard() {
  this._init();
}

Dashboard.prototype._init = function() {
  this.tagsSection = $('div.panels-holder');
  this.statusIndicator = $('.panels-warning');
  this.postButton = $('input.post-status');
  this.successText = "Awesome! You can add more panels that fit your status";
  this.todoText = "You have to select at least 1 panel to post this status";

  this.initNewStatus();
  this.setupPanelsSelection();
  this.setupPostAction();
};

Dashboard.prototype.initNewStatus = function() {
  var that = this;
  $('textarea.feeds-box').bind('focusin', function() {
    $(this).animate({'height': '100px'}, 'fast');
    that.tagsSection.slideDown('fast');
    $('.go-or-not').show();
  });
  $('.cancel-update').click(function(e) {
    e.preventDefault();
    that.tagsSection.slideUp('fast');
    $('.go-or-not').hide();
  });
};

Dashboard.prototype.setupPanelsSelection = function() {
  var that = this;
  this.panels = $('.feeds-container ul.tags li');
  this.panels.click(function(e) {
    e.preventDefault();
    $(this).children('a').toggleClass('selected');
    that.checkPanelsSelection();
  });
};

Dashboard.prototype.checkPanelsSelection = function() {
  var selectedPanels = $('ul.tags a.selected').length;
  if(selectedPanels === 0) {
    this.statusIndicator.removeClass('label-info').addClass('label-warning').text(this.todoText);
    this.postButton.addClass('disabled');
  } else {
    this.statusIndicator.removeClass('label-warning').addClass('label-info').text(this.successText);
    this.postButton.removeClass('disabled');
  }
};

Dashboard.prototype.setupPostAction = function() {
  var that = this;
  $('input.post-status').live('click', function(e) {
    if($(this).hasClass('disabled')) {
      return;
    }
    e.preventDefault();
    if($('textarea.feeds-box').val() === "") {
      alert("Oops. You have to post something right?");
    } else {
      var selectedPanels = $('ul.tags li>a.selected');
      var panels = [];
      $.each(selectedPanels, function(i, obj) {
        panels.push($(obj).attr('data-panel'));
      });
      $.ajax({
        url: "story/create",
        data: { 
          'panels': panels,
          'text': $('textarea.feeds-box').val()
        },
        type: "POST",
        success: function(data) {
          $('textarea.feeds-box').val('');
          $('ul.tags li>a.selected').removeClass('selected');
          that.postButton.addClass('disabled');
          that.statusIndicator.removeClass('label-info').addClass('label-warning').text(that.todoText);

          $('div.panels-holder').slideUp('fast');
          $(data.story).prependTo($('ul.blog-container')).slideDown(1000);
          window._gaq.push(['_trackEvent', 'dashboard', 'story_created', undefined, panels.length]);
        }, error: function(data) {
          var x = 10;
        }
      });
    }
  });
};
