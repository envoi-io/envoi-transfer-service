lib_path = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path) || !File.directory?(lib_path)

require 'set'
require 'json'
require 'aws-sdk-core'
require 'aws-sdk-states'
require 'net/https'
require 'shellwords'

require 'app-logger'

require 'aspera-node-transfer-handler'
require 'aspera-on-cloud-task-handler'

class TransferWorker

  def initialize(args = {})
    @log_request_body = args.fetch(:log_request_body, true)
    @log_response_body = args.fetch(:log_response_body, true)
    @log_pretty_print_body = args.fetch(:log_pretty_print_body, true)

    @logger = args[:logger] || Logger.new($stdout)

    @worker_name = args.fetch(:worker_name, 'transfer-worker')

    states_client_args = args.fetch(:states_client_args, {})

    @states_client = Aws::States::Client.new(states_client_args)
  end

  def logger; @logger end

  def log_request_body; @log_request_body end

  def log_response_body; @log_response_body end

  def log_pretty_print_body; @log_pretty_print_body end

  def states_client; @states_client end

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

  def handle_activity_task_input(input_as_string)
    logger.debug("Handling activity input. Input: #{input_as_string}")

    input = input_as_string.is_a?(String) ? JSON.parse(input_as_string) : input_as_string

    task_type = input['type']
    raise ArgumentError, "Missing 'type' in activity input." unless task_type

    case (task_type || '').downcase
    when 'aspera_on_cloud'
      handler = AsperaOnCloudTaskHandler.new({ input: input, logger: @logger })
    when 'aspera_node_transfer'
      handler = AsperaNodeTransferHandler.new({ input: input, logger: @logger })
    when 's3_copy'
      handler = S3CopyHandler.new({ input: input, logger: @logger })
    else
      throw ArgumentError, "Unhandled Type '#{task_type}'"
    end

    handler.run
  end

  def handle_activity_task(activity_task)

    logger.info("Get activity task : #{activity_task.inspect}")

    input = activity_task.input

    resp = handle_activity_task_input(input)

    # Success
    output = JSON.generate(resp) rescue resp.respond_to?(:to_s) ? resp.to_s : resp
    logger.debug { "Output: #{output}" }
    states_client.send_task_success({
                                task_token: activity_task.task_token,
                                output: output
                            })
    logger.info('Success.')
  rescue StandardError => err
    # Unexpected error
    states_client.send_task_failure({
                                task_token: activity_task.task_token,
                                cause: "[#{@worker_name}] Unexpected error: #{err.message}"
                            })
    logger.error('Unexpected error: ' + err.message)
    logger.debug(err)
  end

  def run(activity_arn)
    logger.info "Starting worker #{@worker_name}..."
    unless activity_arn
      logger.warn('No Activity ARN Specified. Shutting down.')
      return false
    end
    loop do
      begin
        logger.info("Waiting for a task. Press Ctrl-C to interrupt. Monitoring Activity '#{activity_arn}'.")
        activity_task = states_client.get_activity_task({
          activity_arn: activity_arn,
          worker_name: @worker_name
        })
        if activity_task[:task_token]
          time_start = Time.now.to_i
          handle_activity_task(activity_task)
          time_took = Time.now.to_i - time_start
          logger.debug { "Task took #{time_took} seconds." }
        end
      rescue Net::ReadTimeout => e
        logger.warn("#{e.message} while waiting for a task.")
      rescue SignalException => e
        logger.debug("Received Interrupt, shutting down. #{e}")
        break
      rescue StandardError => e
        logger.error("Exception Waiting for Activity: #{e.message}#{e.class.name != e.message ? " #{e.class.name}" : ''}")
      end
    end
  end
end
