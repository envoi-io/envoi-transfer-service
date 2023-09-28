require 'logger'
require 'utils'

class BasicTaskHandler

  attr_accessor :init_args

  def initialize(args = {})
    @init_args = Utils.symbolize_hash_keys(args)
    @task_input = @init_args[:input] || @init_args
    @logger = args[:logger]
  end

  def logger
    @logger || self.class.logger || Logger.new($stdout)
  end

  # def self.logger=(logger)
  #   @@logger = logger
  # end
  #
  # def self.logger
  #   @@logger
  # end

end
