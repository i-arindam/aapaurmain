function IntroHandler(config) {
  this.config = config;
  this._initStepMarkings();
  this.startTour();
  this.enableAnytimeTour();
}

IntroHandler.prototype._initStepMarkings = function() {
  if(this.config.page === 'dashboard') {
    $('.header ul')
      .attr('data-step', '1')
      .attr('data-intro', 'Your profile settings place');
    $('.left-nav')
      .attr('data-step', '2')
      .attr('data-intro', 'Your handy control. Use this to check up interesting areas')
      .attr('data-position', 'top');
    $('.left-nav li.request a')
      .attr('data-step', '3')
      .attr('data-intro', 'List of people who have sent you requests')
      .attr('data-position', 'top');
    $('.left-nav li.follow a')
      .attr('data-step', '4')
      .attr('data-intro', 'List of people who have followed you')
      .attr('data-position', 'top');
    $('.feeds-wrap .share-text')
      .attr('data-step', '5')
      .attr('data-intro', 'Post a story to share your thoughts. That way people will be able to discover you')
      .attr('data-position', 'bottom');
    $('.feeds-wrap ul.tags')
      .attr('data-step', '6')
      .attr('data-intro', 'Select one or more panel that matches your story topic');
    $('.feeds-wrap ul.tags li:nth(0) a')
      .attr('data-step', '7')
      .attr('data-intro', 'All stories are grouped under these panels. Your discoverability increases if you participate in discussion on multiple panels')
  }
};

IntroHandler.prototype.startTour = function() {
  introJs().onchange(function(elem) {
    var obj = $(elem);
    if(obj.attr('data-step') === '5') {
      $('textarea.feeds-box').focus();
    }
  }).
  onexit(function() {
    alert("End of introduction. You can restart it from the link on the header");
  }).
  start();  
};

IntroHandler.prototype.enableAnytimeTour = function() {
  var that = this;
  $('.tour-only a').on('click', function(e) {
    e.preventDefault();
    that._initStepMarkings();
    that.startTour();
  });
};
