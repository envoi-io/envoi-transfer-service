require 'aws-sdk-s3'

require 'basic-task-handler'
class S3CopyHandler < BasicTaskHandler

  def run
    payload = @task_input
    logger.debug { "Payload: #{payload}" }


    config      = payload[:config] || {}
    credentials = config[:credentials]
    if credentials && !credentials.empty?
      config[:credentials] = Aws::Credentials.new(
        credentials[:access_key_id], credentials[:secret_access_key], credentials[:session_token])
    else
      config.delete(:credentials)
    end
    # logger.debug { "Config: #{config}" }
    config[:logger] = logger
    Aws.config.update(config) if config && !config.empty?
    s3 = Aws::S3::Client.new

    arguments = payload[:arguments] || {}
    options   = payload[:options] || {}

    source_object_path                         = arguments[:copy_source]
    source_bucket_name, *source_object_key_ary = source_object_path.split('/')
    source_object_key                          = source_object_key_ary.join('/')
    source_object                              = Aws::S3::Object.new(bucket_name: source_bucket_name, key: source_object_key)
    # source_object_copier                       = Aws::S3::ObjectCopier.new(source_object)
    logger.debug { "Source Object: #{source_object.bucket_name} #{source_object.key}" }

    target_bucket_name = arguments[:bucket]
    target_object_key  = arguments[:key]
    target_object      = Aws::S3::Object.new(bucket_name: target_bucket_name, key: target_object_key)
    logger.debug { "Target Object: #{target_object.bucket_name} #{target_object.key}" }


    logger.debug { "Getting Source Object Head: #{source_bucket_name}/#{source_object_key}" }
    source_object_head = s3.head_object(bucket: source_bucket_name, key: source_object_key)
    logger.debug { "Source Object Head: #{source_object_head}" }

    arguments[:multipart_copy] = true if source_object.content_length >= 5_000_000_000
    # logger.debug { "Getting Target Bucket Head: #{target_bucket_name}" }
    # target_bucket = s3.head_bucket(bucket: target_bucket_name)

    logger.info("S3 Copy - Arguments: #{arguments} Options: #{options}")
    target_object_copier = Aws::S3::ObjectCopier.new(target_object)
    # We use copy_from because it works when copying from a different region
    resp = target_object_copier.copy_from(source_object,arguments)

    # resp = s3.copy_object(arguments, options)
    # resp = source_object.copy_to(arguments)

    resp.to_h
  end

end
