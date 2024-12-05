class Utils

  def self.parse_http_uri_to_s3_args(uri)

  end

  def self.parse_s3_uri_to_s3_args(uri)
    _, bucket_name, *object_key_ary = uri.path.split('/')
    object_key                      = object_key_ary.join('/')
    {
      'access_key'  => uri.user,
      'secret_key'  => uri.password,
      'bucket_name' => bucket_name,
      'object_key'  => object_key,

    }

  end

  def self.uri_to_s3_args(uri)
    uri = URI(uri) if uri.is_a?(String)

    case uri.scheme
    when 's3';
      parse_s3_uri_to_s3_args(uri)

    when 'http', 'https';
      parse_http_uri_to_s3_args(uri)
    end

  end

  def self.symbolize_hash_keys(obj)
    # return Hash[hash.map { |k, v| [ k.to_sym, v ] } ]
    return obj.reduce({}) { |memo, (k, v)| memo.tap { |m| m[k.to_sym] = symbolize_hash_keys(v) } } if obj.is_a? Hash
    return obj.reduce([]) { |memo, v| memo << symbolize_hash_keys(v); memo } if obj.is_a? Array
    obj
  end

end
