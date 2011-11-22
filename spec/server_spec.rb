require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class TestServerHandler
  include EventMachine::Smsified::ServerHandler
end

describe "Smsified Server" do
  before (:each) do
    @sut = TestServerHandler.new
  end

  it "should set the on_incoming callback block" do
    @sut.on_incoming_message do |msg|
    end

  end

  it "should set the on_delivery_notification block" do
    @sut.on_delivery_notification do |msg|
    end
  end

  it "should trigger the on_incoming_message callback block" do
    called = false
    @sut.on_incoming_message do |msg|
      called = true
    end
    @sut.trigger_on_incoming_message(nil)
    called.should be true
  end

  describe "handle" do
    it "should never handle 'GET' requests" do
      @sut.handle("GET", nil).should be false
    end

    it "should not handle invalid string" do
      @sut.handle("GET", "foobar").should be false
    end

    it "should handle 'POST' request with invalid string" do
      @sut.handle("POST", "foobar").should be true
    end

    describe "Incoming Message" do
      before (:all) do
        @json_msg = '{
                "inboundSMSMessageNotification": {
                  "inboundSMSMessage": {
                    "dateTime": "2011-05-11T18:05:54.546Z", 
                    "destinationAddress": "16575550100", 
                    "message": "Inbound test", 
                    "messageId": "ef795d3dac56a62fef3ff1852b0c123a", 
                    "senderAddress": "14075550100"
                  }
                }
              }'
      end
      
      it "should handle POST with content" do
        @sut.handle("POST", @json_msg).should be true
      end

      it "should call a set block with the parsed object" do
        called = false
        @sut.on_incoming_message do |msg|
          msg.instance_of?(EventMachine::Smsified::IncomingMessage).should be true
          called = true
        end
        @sut.handle("POST", @json_msg)
        called.should be true
      end
    end
    describe "Delivery Notification" do
      before (:all) do
        @json_msg = '{ "deliveryInfoNotification": {
                  "deliveryInfo": {
                       "deliveryStatus":"DeliveredToNetwork",
                       "code":"0",
                       "messageId":"2e0b8d79f1084190d50b1c8c1188ad0d",
                       "senderAddress":"tel:+12223334455",
                       "address":"tel:+11112223344",
                       "createdDateTime":"2011-11-22T18:19:51.584Z",
                       "sentDateTime":"2011-11-22T18:19:58.848Z",
                       "parts":"1",
                       "direction":"outbound",
                       "message":"Pong"
                   }
                 }
               }'
      end
      
      it "should handle POST with content" do
        @sut.handle("POST", @json_msg).should be true
      end

      it "should call a set block with the parsed object" do
        called = false
        @sut.on_delivery_notification do |msg|
          msg.instance_of?(EventMachine::Smsified::DeliveryInfoNotification).should be true
          called = true
        end
        @sut.handle("POST", @json_msg)
        called.should be true
      end
    end

  end
end
