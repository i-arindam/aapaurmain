class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  def render_404
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end
  
  def verify_dob(hash)
    return true
  end
  
  def get_date(hash)
    return Date.new(hash[:year].to_i, hash[:month].to_i,hash[:date].to_i)
  end
  
  def verify_age(dob, sex)
    return true
  end
  

  def current_user
    User.find_by_auth_token!(cookies[:auth_token]) if !cookies[:auth_token].blank?
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

end
