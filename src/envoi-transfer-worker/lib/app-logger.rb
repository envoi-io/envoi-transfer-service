require 'logger'

class MultiIO
  attr_accessor :targets
  def initialize(*targets)
    @targets = targets
  end
  def write(*args)
    @targets.each {|t| t.write(*args)}
  end
  def close
    @targets.each(&:close)
  end
end

@logger = nil

def logger;
  @logger
end

args = {}
@log_request_body = args.fetch(:log_request_body, true)

def log_request_body
  @log_request_body
end

@log_response_body = args.fetch(:log_response_body, true)

def log_response_body
  @log_response_body
end

@log_pretty_print_body = args.fetch(:log_pretty_print_body, true)

def log_pretty_print_body
  @log_pretty_print_body
end

def format_body_for_log_output(obj)
  if obj.content_type == 'application/json'
    if @log_pretty_print_body
      body = obj.body
      JSON.pretty_generate(JSON.parse(body)) rescue body
    else
      obj.body
    end
  elsif obj.content_type == 'application/xml'
    obj.body
  else
    obj.body.inspect
  end
end

class AppLogger

  def initialize(args = {})
    @log_request_body = args.fetch(:log_request_body, true)
    @log_response_body = args.fetch(:log_response_body, true)
    @log_pretty_print_body = args.fetch(:log_pretty_print_body, true)

    @logger = args[:logger]

    begin
      @logger ||= Logger.new(MultiIO.new($stdout))
      # require 'remote_syslog_logger'
      # @logger = Logger.new(MultiIO.new(STDOUT, RemoteSyslogLogger::UdpSender.new('logs6.papertrailapp.com', 14679)))
    rescue => e
      @logger = Logger.new($stdout)
    end


  end

  def logger;
    @logger
  end

  def log_request_body
    @log_request_body
  end

  def log_response_body
    @log_response_body
  end

  def log_pretty_print_body
    @log_pretty_print_body
  end

  def format_body_for_log_output(obj)
    if obj.content_type == 'application/json'
      if @log_pretty_print_body
        body = obj.body
        JSON.pretty_generate(JSON.parse(body)) rescue body
      else
        obj.body
      end
    elsif obj.content_type == 'application/xml'
      obj.body
    else
      obj.body.inspect
    end
  end

end
