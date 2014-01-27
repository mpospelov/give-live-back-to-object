require 'spec_helper'
require 'give-live-back-to-object'

describe GiveLive do
  context "when it included in class" do
    class TestClass
      include GiveLive
    end

    describe TestClass do
      subject {TestClass}
      it { should respond_to(:faye_subscribe, :faye_publish, :faye_render) }

      it "should subscribe/publish messages to faye" do
        test_message = {text: "hello world!"}
        subject.faye_subscribe "/test" do |msg|
          msg.should == test_message
        end
        subject.faye_publish("/test", test_message)
      end

    end
  end
  
end
