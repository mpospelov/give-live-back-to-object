require 'eventmachine'
require 'faye'

module GiveLive

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def faye_subscribe(channel, &block)
      wrapped_block = wrap(&block)
      client.subscribe channel, &wrapped_block
    end

    def faye_publish(channel, message)
      client.publish channel, message
    end

    private

    def wrap(&block)
      return lambda do |*args|
        begin
          yield(*args)
        rescue => e
          message = "[ERROR IN FAYE THREAD] #{e.message}\n"
          message << e.backtrace.join("\n")
          defined?(logger) ? logger.error(message) : puts(message)
        end
      end
    end

    def client
      @client ||= begin
        Faye.ensure_reactor_running!
        Faye::Client.new(ENV['FAYE_URL'])
      end
    end
    
  end

end

