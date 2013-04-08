function ProfilePicUpload(){  
  this.user_id = user_object.session_user_id;
  this.thumbnail = $('#user_thumbnail');

  this.uploadButton = $('#upload_placeholder');

  this.deleteButton = $("#deletePhoto");
  this.helpText = $("#helpText");
  this.indicator = $("#indicator");
  this.preview = $("#preview");
  this.successMsg = $("#successMsg");
  this.errorMsg = $("#errorMsg");

  this.initAjaxUpload();
  this.deletePhoto();
};

ProfilePicUpload.prototype.showIndicator = function() {
  this.uploadButton.hide();
  this.deleteButton.hide();
  this.indicator.show();
};

ProfilePicUpload.prototype.initAjaxUpload = function(){
  var that=this;
  var uploader = new qq.FileUploader({
    element: this.uploadButton[0],
    action: '/users/'+ this.user_id + '/upload_photo',
    allowed_extensions: ['jpg','jpeg','png','gif'],
    name: 'userfile',
    template: '<div class="qq-uploader">' +
                '<div class="qq-upload-button" id="uploadText">Upload new image</div>' +
                '<ul class="qq-upload-list"></ul>'+
              '</div>',
    onSubmit: function(file, ext) {
      that.showIndicator();
    },
    onComplete: function(id, file, response) {
      if(response.success === false) {
        that.successMsg.children(":first").text(response.message);
        that.successMsg.show();
        that.indicator.hide();
        that.uploadButton.show();
      } else {
        var photo_url = response.url + '?' + (new Date()).getMilliseconds();
        that.preview.attr('src', photo_url);
        $('#preview').load(function() {
          that.uploadButton.show();
          that.deleteButton.removeClass('hide');
          that.deleteButton.show();
          that.indicator.hide();
        });
      }
    }
  });
};

ProfilePicUpload.prototype.deletePhoto = function(){
  var that = this;
  this.deleteButton.click(function() {
    that.showIndicator();
    $.post('/users/'+ that.user_id + '/delete_photo', {}, function(response) {
      that.indicator.hide();
      if(response.success ===  true) {
        that.preview.attr('src',response.url);
        that.preview.removeAttr("style");
        that.successMsg.children(":first").text("Your profile picture has been deleted!");
        that.successMsg.show();
        that.uploadButton.show();
            that.indicator.hide();
      } else {
        that.successMsg.children(":first").text(response.message);
        that.successMsg.show();
        that.indicator.hide();
        that.uploadButton.show();

        that.deleteButton.show();
      }
    }, 'json');
  });
};

 

  
