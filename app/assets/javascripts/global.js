$(document).ready(function() {
  $('a.close').on('click', function(e) {
    e.preventDefault();
    $(this).parent().toggle('slow');
  });
  $('a[rel=tooltip]').tooltip();
});
