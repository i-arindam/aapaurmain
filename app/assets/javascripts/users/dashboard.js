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
  });
  $('textarea.feeds-box').bind('focusout', function() {
    $(this).animate({'height': '30px'}, 'fast');
  });
  $('.cancel-update').click(function(e) {
    e.preventDefault();
    that.tagsSection.slideUp('fast');
  });
};

Dashboard.prototype.setupPanelsSelection = function() {
  var that = this;
  this.panels = $('ul.tags li');
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
  $('input.post-status:not(:disabled)').live('click', function(e) {
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
          $('div.panels-holder').slideUp('fast');
          $(data.story).prependTo($('ul.blog-container')).slideDown(1000);
        }, error: function(data) {
          var x = 10;
        }
      });
    }
  });
};
