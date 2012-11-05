(function($) {
  $(document).ready(function() {
    var user_id = user_object.session_user_id;
    var thumbnail = $('#user_thumbnail');
 
    var uploadButton = $('#upload_placeholder');
 
    var deleteButton = $("#deletePhoto");
    var helpText = $("#helpText");
    var indicator = $("#indicator");
    var preview = $("#preview");
    var successMsg = $("#successMsg");
    var errorMsg = $("#errorMsg");

    $('.closeThis').click(function() {
      $(this).parent().hide();
    });

    var showIndicator = function() {
      uploadButton.hide();
      deleteButton.hide();
      indicator.show();
    };

    var uploader = new qq.FileUploader({
      element: uploadButton[0],
      action: '/users/'+ user_id + '/upload_photo',
      allowed_extensions: ['jpg','jpeg','png','gif'],
      name: 'userfile',
      template: '<div class="qq-uploader">' +
                  '<div class="qq-upload-button" id="uploadText">Upload new image</div>' +
                  '<ul class="qq-upload-list"></ul>'+
                '</div>',
      onSubmit: function(file, ext) {
        showIndicator();
      },
      onComplete: function(id, file, response) {
        if(response.success === false) {
          errorMsg.children(":first").text(response.message);
          errorMsg.show();
          indicator.hide();
          uploadButton.show();
        } else {
          var photo_url = "https://s3-ap-southeast-1.amazonaws.com/aam-user-photos/profile-"+ user_object.session_user_id + '?'+ (new Date()).getMilliseconds();
           preview.attr('src', photo_url);
           uploadButton.show();
           deleteButton.show();
           indicator.hide();
        }
      }
    });

    deleteButton.click(function() {
      showIndicator();
      $.post('/users/'+ user_id + '/delete_photo', {}, function(response) {
        indicator.hide();
        if(response.success) {
          preview.attr('src','http://placehold.it/96x96');
          preview.removeAttr("style");
          successMsg.children(":first").text("Your profile picture has been deleted!");
          successMsg.show();
          uploadButton.show();
                    indicator.hide();
        } else {
          errorMsg.children(":first").text(response.message);
          errorMsg.show();
          indicator.hide();
          uploadButton.show();

          deleteButton.show();
        }
      }, 'json');
    });

 

  });
})(jQuery);
