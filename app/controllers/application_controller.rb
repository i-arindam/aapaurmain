require 'RMagick'

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  def render_404
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end

  def render_401
    render :file => "#{Rails.root}/public/401.html", :status => 401
  end
  
  def verify_dob(hash)
    return true
  end
  
  def verify_age(dob, sex)
    return true
  end
  

  def current_user
    User.find_by_auth_token!(cookies[:auth_token]) unless cookies[:auth_token].nil?
  end
  helper_method  :current_user
  

  def sanitize_input(in_text)
    ActionController::Base.helpers.strip_tags(in_text)
  end
  helper_method :sanitize_input


  # Returns true if given stream is an image file
  # @param [Object] file The stream that is being checked
  # @return [TrueClass|FalseClass] Returns true if given file is an imagex
  def is_image?(file)
    file, is_temporary = verifyUploadedFileAndConvert(file)
    begin
      response = ['JPEG', 'PNG', 'GIF', 'TIFF', 'BMP'].include?(Magick::Image::read(file.path).first.format)
    rescue
      response = false
    end
    FileUtils.rm(file.path) if is_temporary #Remove tmp file created for iostreams
    response
  end
  
  def is_file_object(file)
    file.respond_to? :read and file.size > 0
  rescue TypeError #For IE, small files are StringIO!
    true
  end
  
  def verifyUploadedFileAndConvert(file)
    if  file.is_a? StringIO or file.is_a? Tempfile or file.is_a? Unicorn::TeeInput
      #opening file in wb+ since same pointer is used to 'read' later
      #todo: optimize
      temp_file = File.new( "temporary-#{rand(100000000).to_s}", "wb+" )
      temp_file.write file.read
      temp_file.flush
      temp_file.rewind
      return temp_file, true
    end
    return file, false
  end
  
  def gimme_random_value(size)
    Time.now.to_i % size
  end
  helper_method :gimme_random_value

  def thumbnail_pic_url(user_id)
    user = User.find user_id
    if user && user.photo_exists
      key = $aapaurmain_conf['thumbnail']
      profile_key = key.gsub('{{user_id}}' , user_id.to_s)
      $aapaurmain_conf['aws-origin-server'] + $aapaurmain_conf['aws']['photo-bucket'] + '/' + profile_key + '?' + gimme_random_value(10).to_s
    else
      "/assets/users/image_placeholder_small.png"
    end
  end
  helper_method :thumbnail_pic_url
  
  def original_pic_url(user_id)
    user = User.find user_id
    if user && user.photo_exists
      key = $aapaurmain_conf['profile-pic-original']
      profile_key = key.gsub('{{user_id}}' , user_id.to_s)
      $aapaurmain_conf['aws-origin-server'] + $aapaurmain_conf['aws']['photo-bucket'] + '/' + profile_key + '?' + gimme_random_value(10).to_s
    else
      "/assets/users/image_placeholder.png"
    end
  end
  helper_method :original_pic_url

  def decorate_redis_time(time_in_string)
    decorate_time(Time.parse(time_in_string))
  end

  def decorate_time(time)
    view_context.distance_of_time_in_words_to_now(time)
  end

  def get_display_for_list_page(users, main_user)
    objects = []
    users.each do |u|
      objects.push({
        :user => u,
        :request => Request.get_request_values(main_user, u)
      })
    end
    objects
  end

end
