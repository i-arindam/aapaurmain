function GAHandler(config) {
  this.config = config;
  this._init();
}

GAHandler.prototype._init = function() {
  this.createTrackingFunctions();
  this.config.q.push(['_trackPageview', this.config.page]);
  this.setupClickBindings();
};

GAHandler.prototype.createTrackingFunctions = function() {
  var that = this;
  $.fn.extend({
    trackClick: function(category, action, label, value) {
      return this.on('click', function(e) {
        that.config.q.push(['_trackEvent', category, that.config.pre + action, label, value]);
        return true;
      });
    },
    trackPageTypeClick: function(action) {
      $.fn.trackClick.call(this, that.config.page, action);
    },
    trackListPageRequest: function() {
      return this.on('click', function(e) {
        var action = $(this).attr('href').match(/#request_(\w+)/)[1];
        that.config.q.push(['_trackEvent', that.config.page, 'list_request_' + action]);
        return true;
      });
    },
    trackListPageFollow: function() {
      return this.on('click', function(e) {
        var action = ($(this).hasClass('follow') ? "follow" : "unfollow");
        that.config.q.push(['_trackEvent', that.config.page, 'list_' + action]);
        return true;
      });
    },
    trackListPageRate: function() {
      return this.on('click', function() {
        $('div.star img').live('click', function(e) {
          that.config.q.push(['_trackEvent', that.config.page, 'list_user_rate', undefined, $(this).attr('alt')]);
        });
      });
    }
  });
};

GAHandler.prototype.setupClickBindings = function() {
  this.setupTrackingForStory();
  this.setupTrackingForLeftNav();
  (this.config.pageType === 'list' || this.config.pageType === 'profile') && this.setupTrackingForUserProfiles();
  this.config.pageType === 'dashboard' && this.setupTrackingForDashboard();
};

GAHandler.prototype.setupTrackingForStory = function() {
  $('li.story .story-creator a').trackPageTypeClick('user_profile_click');
  $('li.story a.story-time').trackPageTypeClick('full_story_click');
  $('li.story ul.story-tags a').trackPageTypeClick('story_panel_click');
  $('li.story a.link-like').trackPageTypeClick('story_liked');
  $('li.story a.link-dislike').trackPageTypeClick('story_disliked');
  $('li.story .comment-count-wrap a').trackPageTypeClick('story_comment_show');
  $('li.story .j-show-claps').trackPageTypeClick('show_claps');
  $('li.story .j-show-boos').trackPageTypeClick('show_boos');
  $('li.story .link-like-comment').trackPageTypeClick('comment_liked');
  $('li.story .link-dislike-comment').trackPageTypeClick('comment_disliked');
  $('li.story .j-show-comment-claps').trackPageTypeClick('show_comment_claps');
  $('li.story .j-show-comment-boos').trackPageTypeClick('show_comment_boos');
};

GAHandler.prototype.setupTrackingForLeftNav = function() {
  $('.left-nav li:nth(0) a').trackPageTypeClick('left_nav_my_profile_click');
  $('.left-nav li:nth(1) a').trackPageTypeClick('left_nav_incoming_request_click');
  $('.left-nav li:nth(2) a').trackPageTypeClick('left_nav_outgoing_request_click');
  $('.left-nav li:nth(3) a').trackPageTypeClick('left_nav_people_i_follow_click');
  $('.left-nav li:nth(4) a').trackPageTypeClick('left_nav_people_follow_me_click');
};

GAHandler.prototype.setupTrackingForDashboard = function() {
  $('a.more-stories').trackPageTypeClick('more_stories_clicked');
};

GAHandler.prototype.setupTrackingForUserProfiles = function() {
  $('a.req-button').trackListPageRequest();
  $('a.link-follow-user').trackListPageFollow();
  $('a.link-rate-profile').trackListPageRate();
  $('a.rs-next').trackPageTypeClick('next_user_clicked');
  $('a.rs-prev').trackPageTypeClick('prev_user_clicked');
};
