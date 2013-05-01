function ProfilePicUpload(auto_thumbnail){  
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
  if(auto_thumbnail) {
    this.askForThumbnail($('#preview').attr('src'));
  }
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
        var toRemove = response.url.match(/.*profile\-\d+(\?\d+).*/)[1];
        var photoUrl = response.url.replace(toRemove, "");

        that.preview.attr('src', photoUrl);
        $('#preview').load(function() {
          that.uploadButton.show();
          that.deleteButton.removeClass('hide');
          that.deleteButton.show();
          that.indicator.hide();
          that.askForThumbnail(photoUrl);
          that.listenForThumbnailChosen();
        });
      }
    },
    onError: function(id, name, reason, xhr) {
      alert('failed. Try again in some time please');
    }
  });
};

ProfilePicUpload.prototype.askForThumbnail = function(url) {
  var mod = $('#choose-thumb-modal');
  mod.modal('show');
  var random = (new Date()).getMilliseconds();
  mod.find('.main-img').attr('src', url + "?" + random);
  var that = this;
  img = $('.main-img');
  this.origImgW = img[0].naturalWidth;
  this.origImgH = img[0].naturalHeight;

  var ar = "" + this.origImgW + ":" + this.origImgH;

  img.load(function() {
    if(!that.imgCreated) {
      that.ias = $('.main-img').imgAreaSelect({
        handles: true,
        keys: true,
        maxWidth: 500, 
        maxHeight: 500,
        minHeight: 90,
        minWidth: 90,
        persistent: true,
        x1: 100,
        y1: 100,
        x2: 250,
        y2: 250,
        instance: true,
        onSelectEnd: function (img, sel) {
          $('input[name=x1]').val(sel.x1);
          $('input[name=y1]').val(sel.y1);
          $('input[name=width]').val(sel.width);
          $('input[name=height]').val(sel.height);
        },
        onInit: function() {
          that.ias.setSelection(100, 100, 250, 250);
          that.ias.setOptions({ show: true });
          that.ias.update();
        },
      });
    }
  });
};

ProfilePicUpload.prototype.listenForThumbnailChosen = function() {
  var that = this;
  $('.modal .submit-area a').on('click', function(e) {
    $(this).text("Creating...").addClass('disabled');
    e.preventDefault();
    $.ajax({
      url: '/users/' + that.user_id + '/generate_thumbnail',
      type: "POST",
      data: {
        'x1': $('input[name=x1]').val(),
        'y1': $('input[name=y1]').val(),
        'width': $('input[name=width]').val(),
        'height': $('input[name=height]').val()
      },
      dataType: "json",
      success: function(data) {
        $('#choose-thumb-modal').modal('hide');
        that.ias.remove();
        that.imgCreated = true;
        $('#preview').attr('src', data.display_url + "?" + (new Date()).getMilliseconds());
      }, error: function(data) {
        $('#choose-thumb-modal').modal('hide');
        that.ias.remove();
        that.imgCreated = false;
        alert("Something went wrong. Try again in some time");
      }
    });
  });
};

ProfilePicUpload.prototype.deletePhoto = function(){
  var that = this;
  this.deleteButton.click(function() {
    that.showIndicator();
    $.ajax({
      url: '/users/' + that.user_id + '/delete_photo',
      type: "POST",
      dataType: "json",
      success: function(response) {
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
      }
    });
  });
};
