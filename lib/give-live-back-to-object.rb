# require 'give_live_back_to_object/callbacks'
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

    def faye_render(attrs)
      raise "Error" if attrs[:template].blank? || attrs[:selector].blank?
      faye_publish("/give_live_back_to_object/render/", attrs)
    end

    private

    def wrap(&block)
      return lambda do |*args|
        begin
          yield(*args)
        rescue => e
          message = "[ERROR IN FAYE THREAD] #{e.message}"
          message << e.backtrace.join("\n")
          defined?(logger) ? logger.error(message) : puts(message)
        end
      end
    end

    def client
      @client ||= begin
                    Thread.new { EM.run } unless EM.reactor_running?
                    Thread.pass until EM.reactor_running?
                    Faye::Client.new('http://localhost:9292/faye')
                  end
    end
    
  end

end

