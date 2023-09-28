require 'net/https'

require 'basic-task-handler'
class AsperaNodeTransferHandler < BasicTaskHandler

  def run
    source_config = @task_input['source']

    source_url    = source_config['url']
    return unless source_url
    source_uri    = URI(source_url)
    source_path   = CGI.unescape(source_uri.path || '')
    source_uri.port ||= 9092

    # source_transfer_args = CGI.parse(source_uri.query || '')

    target_config = args['target'] || args['destination']
    target_url    = target_config['url']
    target_uri    = URI(target_url)
    target_path   = CGI.unescape(target_uri.path || '')
    target_uri.port ||= 33_001

    target_transfer_args = CGI.parse(target_uri.query || '')

    # Change values from array to string with comma separated values
    target_transfer_args_flattened = {}
    target_transfer_args.each { |k, v| target_transfer_args_flattened[k] = v.join(',') }

    transfer_spec = {
      'remote_host' => target_uri.host,
      'remote_user' => target_uri.user,
      'authentication' => 'password',
      'remote_password' => target_uri.password,
      'ssh_port' => target_uri.port,
      'fasp_port' => target_uri.port,
      'paths' => [{ 'source' => source_path }],
      'direction' => 'send',
      'destination_root' => target_path
    }
    transfer_spec.merge!(target_transfer_args_flattened)

    aspera_make_node_request(source_uri, '/ops/transfers', transfer_spec)
  end

  def aspera_make_node_request(base_uri, path, spec)
    uri = base_uri.is_a?(String) ? URI(base_uri) : base_uri
    http = Net::HTTP.new(uri.host || '', uri.port)
    http.use_ssl = true
    # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(path, { 'Content-Type' => 'application/json' })
    request.basic_auth(uri.user || '', uri.password || '')
    request.body = spec.to_json
    logger.debug { %(REQUEST: #{request.method} http#{http.use_ssl? ? 's' : ''}://#{http.address}:#{http.port}#{request.path} HEADERS: #{request.to_hash.inspect} #{log_request_body and request.request_body_permitted? ? "\n-- BODY BEGIN --\n#{format_body_for_log_output(request)}\n-- BODY END --" : ''}) }

    response = http.request(request)
    logger.debug { %(RESPONSE: #{response.inspect} HEADERS: #{response.to_hash.inspect} #{log_response_body and response.respond_to?(:body) ? "\n-- BODY BEGIN --\n#{format_body_for_log_output(response)}\n-- BODY END--" : ''}) }

    response.body
  end

end
