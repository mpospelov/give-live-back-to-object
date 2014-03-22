require 'spec_helper'
require 'give-live-back-to-object'
require 'byebug'

describe GiveLive do
  context "when it included in class" do

    class TestClass
      include GiveLive
    end

    describe TestClass do
      ENV['FAYE_URL'] = "http://localhost:9292/faye"

      subject { TestClass }
      it { should respond_to(:faye_subscribe, :faye_publish) }

      it "should subscribe/publish messages to faye" do
        message_recived = false
        test_message = { text: "hello world!" }

        debugger
        Thread.new{
          subject.faye_subscribe "/test" do |msg|
            message_recived = true
            msg.should == test_message
          end
        }

        while not message_recived
          subject.faye_publish("/test", test_message)
        end
      end

    end
  end
  
end
