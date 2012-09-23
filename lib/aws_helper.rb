#!/usr/local/bin/ruby

require 'rubygems'
require 'right_aws'
require 'mime/types'
require 'find'


class AWSHelper
  attr_reader :access_key, :secret_key
  MAX_TRIES = 3
  def initialize(access_id, secret_id)
    @access_key = access_id
    @secret_key = secret_id
  end

  #delete_file
  #deletes the given file from the given bucket
  def delete_file(file, bucket = 'aam-user-photos')
    s3 = RightAws::S3Interface.new(@access_key, @secret_key, {:logger => $logger})
    return s3.delete(bucket, file)
  end


  #put_data
  #puts given data into s3 bucket with the given key name
  def put_data(data, file, bucket= 'slideshare', acl_value = 'public-read')
    begin
      s3 = RightAws::S3Interface.new(@access_key, @secret_key, {:logger => $logger})
      content_type = MIME::Types.of(File.basename(file)).to_a.join(',')
      content_type = 'text/plain' if content_type == ""
      return s3.put(bucket, File.basename(file), data, {'x-amz-acl' => acl_value, 'Content-Type' => content_type})
    rescue Exception => e
      $logger.warn(e.inspect)
      return false
    end
  end

#put_file
#puts a given file into given bucket
def put_file(file, bucket = 'aam-user-photos', headers)
  unless file
    return 0
  end
  tries = 0
  return 0 if not FileTest.file?(file)
  while true do
    begin
      return 0 if tries > MAX_TRIES
      s3 = RightAws::S3Interface.new(@access_key, @secret_key)

      return 1 if s3.put(bucket, File.basename(file), File.open(file), headers)
      tries = tries + 1
    rescue Exception => e
      $logger.warn(e.inspect)
      tries = tries + 1
    end
  end
end

#put_file with the given key
#puts a given file into given bucket with the given key name
def put_file_with_key(file, key, bucket = 'slideshare', acl_value = 'public-read', s3interface = nil)
unless file and key
  return false
end
tries = 0
if FileTest.file?(file)
  while true do
    begin
      return false if tries > MAX_TRIES
      content_type = MIME::Types.of(File.basename(file)).to_a.join(',')
      content_type = 'text/plain' if content_type == ""
      if s3interface != nil
        s3 = s3interface
      else
        s3 = RightAws::S3Interface.new(@access_key, @secret_key, {:logger => $logger})
      end
      return true if s3.put(bucket, key, File.open(file), {'x-amz-acl' => acl_value, 'Content-Type' => content_type})
      tries = tries + 1
    rescue Exception => e
      $logger.warn(e.inspect)
      tries = tries + 1
    end
  end
end
end

#put_directory
#puts given directory (all files present in the directory)into given bucket
def put_directory(directory, bucket = 'slideshare', acl_value = 'public-read', file_types = nil)
unless directory
	return false
end
files = []

Find.find(directory) do |path|
  basename = File.basename(path)
  Find.prune if basename[0] == ?. if FileTest.directory?(path)
  files << path if FileTest.file?(path) and (file_types == nil or file_types.include?(File.extname(path)))
end
files.sort!

if files.length > 0
  s3 = RightAws::S3Interface.new(@access_key, @secret_key, {:logger => $logger})
  files.each do |filename|
    $logger.info("Uploading #{filename}")
    put_file(filename, bucket, acl_value, s3)
  end
end
end



end
