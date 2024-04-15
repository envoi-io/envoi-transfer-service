require 'aws-sdk-s3'

DEFAULT_TEMP_DIR_PATH = ENV['TEMP_DIR'] || '/tmp/' unless defined? DEFAULT_TEMP_DIR_PATH

module S3Service
  class << self
    def upload_file(from:, to:, bucket:)
      object = object(to, bucket:)
      object.upload_file(from)
      object.presigned_url(:get)
    end

    def download_file(key:, to:, bucket:, options: {})
      object = object(key, bucket:, options:)
      object.download_file(to)
    end

    def get_download_link(file_name, bucket:)
      object(file_name, bucket:).presigned_url(:get).to_s
    end

    private

    def object(file_name, bucket:, options: {})
      bucket(bucket, options).object(file_name)
    end

    def bucket(bucket, options = {})
      Aws::S3::Resource.new(options).bucket(bucket)
    end
  end
end

class S3Helper

  def initialize(args = {})
    @client = args[:client] || Aws::S3::Client.new
  end

  def download_file(key:, to:, bucket:)
    object = object(key, bucket:)
    object.download_file(to)
  end

  def get_download_link(file_name, bucket:)
    object(file_name, bucket:).presigned_url(:get).to_s
  end

  private

  def object(file_name, bucket:, options: {})
    bucket(bucket, options).object(file_name)
  end

  def bucket(bucket, options = {})
    Aws::S3::Resource.new(options).bucket(bucket)
  end

end

class S3Downloader

  def initialize(args: {}, url: nil, uri: nil, credentials: nil)
    @init_args = args.dup

    args_from_url = nil
    args_from_url = url_to_args(uri:, url:, args:) if uri || url
    @args = args_from_url || args
    @args[:credentials] = credentials if credentials

    @temp_dir = args[:temp_dir] || DEFAULT_TEMP_DIR_PATH
  end

  def url_to_args(uri: nil, url: nil, args: {})
    uri = URI(uri || url)

    credentials = args[:credentials] || {}
    access_key = uri.user
    secret_key = uri.password
    credentials[:access_key_id] ||= access_key if access_key
    credentials[:secret_access_key] ||= CGI.unescape(secret_key) if secret_key

    if credentials.empty?
      begin
        credentials = Aws::InstanceProfileCredentials.new
      rescue StandardError => e
        puts "Exception setting credentials = Aws::InstanceProfileCredentials. #{e.message}"
      end
    end


    bucket_name = uri.host
    object_key = uri.path || ''
    object_key.slice!(0) if object_key.start_with?('/')
    object_key.gsub('+', ' ')
    {
      credentials:,
      bucket_name:,
      object_key:
    }
  end

  def download
    bucket_name = @args[:bucket_name]
    object_key = @args[:object_key]

    options = {}
    credentials = @args[:credentials]

    aws_credentials = nil
    # aws_credentials = Aws::SharedCredentials.new(credentials) if credentials
    aws_credentials = credentials.is_a?(Hash) ? Aws::Credentials.new(credentials[:access_key_id], credentials[:secret_access_key]) : credentials if credentials
    options[:credentials] = aws_credentials if aws_credentials


    destination_file_name = @init_args[:destination_file_name] || File.basename(object_key)

    destination = File.join(@temp_dir, destination_file_name)
    S3Service.download_file(key: object_key, to: destination, bucket: bucket_name, options:)

    {
      destination:,
      destination_file_name:
    }
  end

end
