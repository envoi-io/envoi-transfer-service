require 'logger'
require 'utils'

# A basic task handler class that provides a logger and input handling.
class BasicTaskHandler

  attr_accessor :init_args

  def initialize(args = {})
    @init_args = Utils.symbolize_hash_keys(args)
    @task_input = @init_args[:input] || @init_args
    @logger = args[:logger]
  end

  def logger
    @logger ||= self.class.logger || Logger.new($stdout)
  end

end
