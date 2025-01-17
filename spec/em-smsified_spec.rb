require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# These tests are all local unit tests
WebMock.disable_net_connect!

def wrap_and_run(obj, message, *args)
  EventMachine.run_block do
    obj.send(message, *args) do |response|
      return response
    end
  end
end


describe "Smsified" do
  def failed
    EventMachine.stop
    fail
  end

  before(:all) do
    @username       = 'user'
    @password       = 'pass'
    @address        = '14155551212'
    @sender_address = '13035551212'
    @request_uri = "https://api.smsified.com/v1/smsmessaging/outbound/#{@sender_address}/requests"
  end
  
  describe "Helpers" do
    before(:all) do
      class Foo
        include EventMachine::Smsified::Helpers
        
        attr_reader :keys, :query_string 
        
        def initialize(hash)
          @keys = camelcase_keys(hash)
          @query_string = build_query_string(hash)
        end
      end
      
      @foo = Foo.new({ :destination_address => 'foo',
                       :notify_url          => 'bar',
                       :client_correlator   => 'baz',
                       :callback_data       => 'donkey' })
    end
    
    it 'Should camelcase the appropriate keys' do                                  
      camelcased_keys = @foo.keys
      
      camelcased_keys[:destinationAddress].should eql 'foo'
      camelcased_keys[:notifyURL].should eql 'bar'
      camelcased_keys[:clientCorrelator].should eql 'baz'
      camelcased_keys[:callbackData].should eql 'donkey'
    end
    
    it 'Should build a proper query string' do
      @foo.query_string.should eql "destinationAddress=foo&notifyURL=bar&clientCorrelator=baz&callbackData=donkey"
    end
  end
  
  describe "OneAPI" do
    before(:all) do
      @one_api = EventMachine::Smsified::OneAPI.new :username => @username, :password => @password, :debug => true
      
      @message_sent = { "resourceReference" => { "resourceURL" => "https://api.smsified.com/v1/smsmessaging/outbound/tel%3A%2B#{@sender_address}/requests/795bd02c8e343b2dfd673b67dd0ee55a" } }
    end

    before(:each) do
      #Because WebMock configures a global RSpect WebMock.reset!, we need to set up the stub before each spec instead of on :all
      stub_request(:post, @request_uri).
        to_return(:status => 200, :body => @message_sent.to_json, :headers => {})
    end
    
    it "Should get errors if instantiating without all of the right parameters" do
      begin
        EventMachine::Smsified::OneAPI.new 'foobar'
      rescue => e
        e.to_s.should eql 'an options Hash is required'
      end

      begin
        EventMachine::Smsified::OneAPI.new(:password => nil)
      rescue => e
        e.to_s.should eql ':username required'
      end
      
      begin
        EventMachine::Smsified::OneAPI.new(:username => @username)
      rescue => e
        e.to_s.should eql ':password required'
      end
    end
    
    it "Should raise an error if no :sender_address specified" do
      begin
        @one_api.send_sms('foobar')
      rescue => e
        e.to_s.should eql 'an options Hash is required'
      end
      
      begin
        @one_api.send_sms({})
      rescue => e
        e.to_s.should eql ':sender_address is required'
      end
    end
    
    it "Should not raise an error if a :sender_address was specified at instantiation" do
      one_api = EventMachine::Smsified::OneAPI.new :username => @username, :password => @password, :debug => true, :sender_address => @sender_address

      response = wrap_and_run(one_api, :send_sms, :address => @address, :message => 'Hola from RSpec!') 

      response.data.should eql @message_sent
    end
    
    it "Should raise an error if all required params are not passed when sending an SMS" do
      begin
        @one_api.send_sms(:message => 'Hola from RSpec!', :sender_address => @sender_address)
      rescue => e
        e.to_s.should eql ':address is required'
      end
      
      begin
        @one_api.send_sms(:address => @address, :sender_address => @sender_address)
      rescue => e
        e.to_s.should eql ':message is required'
      end
    end
    
    it "Should instantiate a OneAPI object" do
      oneapi = EventMachine::Smsified::OneAPI.new :username => @username, :password => @password, :debug => true
      oneapi.instance_of?(EventMachine::Smsified::OneAPI).should eql true
    end
    
    it "Should send an SMS" do
      response = wrap_and_run(@one_api, :send_sms, :address => @address, :message => 'Hola from RSpec!', :sender_address => @sender_address)

      response.data.should eql @message_sent

      a_request(:post, @request_uri).
        with{ |req| req.body == "address=14155551212&message=Hola+from+RSpec%21"}.should have_been_made
    end
    
    it "Should send an SMS to multiple destinations" do
      response = wrap_and_run(@one_api, :send_sms, :address        => ['14155551212', '13035551212'], 
                              :message        => 'Hola from RSpec!', 
                              :sender_address => @sender_address)
      response.data.should eql @message_sent

      a_request(:post, @request_uri).
        with{ |req| req.body == "address=14155551212&address=13035551212&message=Hola+from+RSpec%21"}.should have_been_made
    end
  end
  
  describe 'Subscriptions' do
    before(:all) do
      @subscriptions = EventMachine::Smsified::Subscriptions.new :username => @username, :password => @password, :debug => true
    end
    
    it "Should instantiate a Subscriptions object" do
      smsified = EventMachine::Smsified::Subscriptions.new(:username => @username, :password => @password)
      smsified.instance_of?(EventMachine::Smsified::Subscriptions).should eql true
    end
    
    it "Should get errors if instantiating without all of the right parameters" do
      begin
        EventMachine::Smsified::Subscriptions.new 'foobar'
      rescue => e
        e.to_s.should eql 'an options Hash is required'
      end
      
      begin
        EventMachine::Smsified::Subscriptions.new({})
      rescue => e
        e.to_s.should eql ':username required'
      end
      
      begin
        EventMachine::Smsified::Subscriptions.new(:username => @username)
      rescue => e
        e.to_s.should eql ':password required'
      end
    end

    describe 'Listing subscriptions' do
      before(:all) do
        @no_subscription = { "inboundSubscriptionList" => { "numberOfSubscriptions" => "0" } }
        
        @inbound_subscriptions = {
          "inboundSubscriptionList" => {
            "inboundSubscription" => [
                                      {
                                        "resourceURL" => "https://api.smsified.com/v1/smsmessaging/inbound/subscriptions/3cf88f9cfd0dae96cbfdf16f18c07411",
                                        "subscriptionId" => "3cf88f9cfd0dae96cbfdf16f18c07411",
                                        "notificationFormat" => "JSON",
                                        "destinationAddress" => "tel:+17177455076",
                                        "notifyURL" => "http://98.207.5.162:8080"
                                      },
                                      {
                                        "resourceURL" => "https://api.smsified.com/v1/smsmessaging/inbound/subscriptions/75bb5bef239aed425c2966cbb95f33c9",
                                        "subscriptionId" => "75bb5bef239aed425c2966cbb95f33c9",
                                        "notificationFormat" => "JSON",
                                        "destinationAddress" => "tel:+17177455076",
                                        "notifyURL" => "http://98.207.5.162:8080"
                                      }
                                     ],
            "numberOfSubscriptions" => "2",
            "resourceURL" => "https://api.smsified.com/v1/smsmessaging/inbound/subscriptions"
          }
        }
        
        @outbound_subscriptions = {
          "outboundSubscriptionList" => {
            "numberOfSubscriptions" => "2",
            "resourceURL" => "https://api.smsified.com/v1/smsmessaging/outbound/subscriptions",
            "outboundSubscription" => [
                                       {
                                         "senderAddress" => "tel:+17177455076",
                                         "resourceURL" => "https://api.smsified.com/v1/smsmessaging/outbound/subscriptions/68faa512b1c81ee0d33a6b97004d1212",
                                         "subscriptionId" => "68faa512b1c81ee0d33a6b97004d1212",
                                         "notificationFormat" => "JSON",
                                         "notifyURL" => "http://98.207.5.162:8080"
                                       },
                                       {
                                         "senderAddress" => "tel:+17177455076",
                                         "resourceURL" => "https://api.smsified.com/v1/smsmessaging/outbound/subscriptions/6e64fb72cd2a27b8a9460caccbd4dc53",
                                         "subscriptionId" => "6e64fb72cd2a27b8a9460caccbd4dc53",
                                         "notificationFormat" => "JSON",
                                         "notifyURL" => "http://98.207.5.162:8080"
                                       }
                                      ]
          }
        }
      end
      before(:each) do
        stub_request(:get, 
                     "https://api.smsified.com/v1/smsmessaging/inbound/subscriptions?destinationAddress=#{@address}").
          with(:headers => {'Authorization' => [@username, @password]}).
          to_return(:status => ["200", "OK"],
                    :body   => @no_subscription.to_json)
        
        stub_request(:get, 
                     "https://api.smsified.com/v1/smsmessaging/inbound/subscriptions?destinationAddress=#{@sender_address}").
          with(:headers => {'Authorization' => [@username, @password]}).
          to_return(:status => ["200", "OK"],
                    :body   => @inbound_subscriptions.to_json)

        stub_request(:get, 
                     "https://api.smsified.com/v1/smsmessaging/outbound/subscriptions?senderAddress=#{@sender_address}").
          with(:headers => {'Authorization' => [@username, @password]}).
          to_return(
                    :status => ["200", "OK"],
                    :body   => @outbound_subscriptions.to_json)
      end
      
      it "Should let me instantiate a OneAPI object and call subscription methods" do
        one_api = EventMachine::Smsified::OneAPI.new :username => @username, :password => @password, :debug => true
        inbound_subscriptions = wrap_and_run(one_api, :inbound_subscriptions, @address)
        inbound_subscriptions.data.should eql @no_subscription
      end
      
      it "Should find no subscriptions" do
        inbound_subscriptions = wrap_and_run(@subscriptions, :inbound_subscriptions, @address)
        inbound_subscriptions.data.should eql @no_subscription
      end
      
      it "Should get a list of inbound subscriptions" do
        inbound_subscriptions = wrap_and_run(@subscriptions, :inbound_subscriptions, @sender_address)
        inbound_subscriptions.http.response_header.status.should eql 200
        inbound_subscriptions.data.should eql @inbound_subscriptions
      end

      it "Should get a list of outbound subscriptions" do
        outbound_subscriptions = wrap_and_run(@subscriptions, :outbound_subscriptions, @sender_address)
        outbound_subscriptions.http.response_header.status.should eql 200
        outbound_subscriptions.data.should eql @outbound_subscriptions
      end
    end
    
    describe 'Create subscriptions' do
      before(:all) do
        @inbound_subscription  = { "resourceReference" => { "resourceURL" => "https://api.smsified.com/v1/smsmessaging/inbound/subscriptions/e636368b7fddac0e93e34ae03bad33dd" } }
        @outbound_subscription = { "resourceReference" => { "resourceURL" => "https://api.smsified.com/v1/smsmessaging/outbound/subscriptions/4bc465cd394c9f5e78802af5ad6bb442" } }
        @inbound_uri = %r|https://api.smsified.com/v1/smsmessaging/inbound/subscriptions?|
        @outbound_uri = %r|https://api.smsified.com/v1/smsmessaging/outbound/17177455076/subscriptions?|
      end
      
      it 'Should create an inbound subscription' do
        stub_request(:post, @inbound_uri).
          with(:headers => {'Authorization' => [@username, @password]}).
          to_return(:status => ["200", "OK"],
                    :body   => @inbound_subscription.to_json)

        result = wrap_and_run(@subscriptions, :create_inbound_subscription, '17177455076', :notify_url => 'http://foobar.com')
        result.http.response_header.status.should eql 200
        result.data.should eql @inbound_subscription
        a_request(:post, @inbound_uri).
          with{ |req| req.body == "destinationAddress=17177455076&notifyURL=http%3A%2F%2Ffoobar.com"}.should have_been_made
      end
      
      it 'Should create an outbound subscription' do
        stub_request(:post, @outbound_uri).
          with(:headers => {'Authorization' => [@username, @password]}).
          to_return(:status => ["200", "OK"],
                    :body   => @outbound_subscription.to_json)

        result = wrap_and_run(@subscriptions, :create_outbound_subscription, '17177455076', :notify_url => 'http://foobar.com')
        result.http.response_header.status.should eql 200
        result.data.should eql @outbound_subscription
        a_request(:post, @outbound_uri).
          with{ |req| req.body == "notifyURL=http%3A%2F%2Ffoobar.com"}.should have_been_made
      end
    end
    
    describe 'Updated subscriptions' do
      before(:all) do
        @inbound_subscription  = { "resourceReference" => { "resourceURL" => "https://api.smsified.com/v1/smsmessaging/inbound/subscriptions/e636368b7fddac0e93e34ae03bad33dd" } }
        @outbound_subscription = { "resourceReference" => { "resourceURL" => "https://api.smsified.com/v1/smsmessaging/outbound/subscriptions/4bc465cd394c9f5e78802af5ad6bb442" } }

        @inbound_uri = %r|https://api.smsified.com/v1/smsmessaging/inbound/subscriptions?|

        @outbound_uri = "https://api.smsified.com/v1/smsmessaging/outbound/#{@sender_address}/subscriptions"
      end
      
      it 'Should update an inbound subscription' do
        stub_request(:post, @inbound_uri).
          with(:headers => {'Authorization' => [@username, @password]}).
          to_return(:status => ["200", "OK"],
                    :body   => @inbound_subscription.to_json)

        result = wrap_and_run(@subscriptions, :update_inbound_subscription, 'c880c96f161f6220d4977b29b4bfc111', :notify_url => 'http://foobar1.com')

        result.http.response_header.status.should eql 200
        result.data.should eql @inbound_subscription
        a_request(:post, @inbound_uri).
          with{ |req| req.body == "notifyURL=http%3A%2F%2Ffoobar1.com"}.should have_been_made
      end
      
      it 'Should update an outbound subscription' do
        stub_request(:post, @outbound_uri).
          with(:headers => {'Authorization' => [@username, @password]}).
          to_return(:status => ["200", "OK"],
                    :body   => @outbound_subscription.to_json)

        result = wrap_and_run(@subscriptions, :update_outbound_subscription, @sender_address, :notify_url => 'http://foobar.com')
        result.http.response_header.status.should eql 200
        result.data.should eql @outbound_subscription
        a_request(:post, @outbound_uri).
          with{ |req| req.body == "notifyURL=http%3A%2F%2Ffoobar.com" }.should have_been_made
      end
    end
    
    describe 'Deleting subscriptions' do
      before(:each) do
        stub_request(:delete, %r|https://api.smsified.com/v1/smsmessaging/?|).
          with(:headers => {'Authorization' => [@username, @password]}).
          to_return(:status => ["204", "OK"])        
      end
      
      it "Should delete an inbound subscription" do
        result = wrap_and_run(@subscriptions, :delete_inbound_subscription, '3cf88f9cfd0dae96cbfdf16f18c07411')
        result.http.response_header.status.should eql 204
      end
      
      it "Should delete an outbound subscription" do

        result = wrap_and_run(@subscriptions, :delete_outbound_subscription, '342b61efc3ba9fd2fd992e58903ef050')
        result.http.response_header.status.should eql 204
      end
    end
  end
  
  describe "Reporting" do
    before(:all) do
      @reporting = EventMachine::Smsified::Reporting.new :username => @username, :password => @password, :debug => true
      
      @delivery_status = {
        "deliveryInfoList" => {
          "deliveryInfo" => [
                             {
                               "address" => "tel:+14153675082",
                               "parts" => "1",
                               "senderAddress" => "tel:+17177455076",
                               "messageId" => "74ae6147f915eabf87b35b9ea30c5916",
                               "code" => "0",
                               "createdDateTime" => 'Fri May 13 16:14:50 UTC 2011',
                               "sentDateTime" => 'Fri May 13 16:14:53 UTC 2011',
                               "deliveryStatus" => "DeliveredToNetwork",
                               "message" => "Hola from RSpec!",
                               "direction" => "outbound"
                             }
                            ],
          "resourceURL" => "https://api.smsified.com/v1/smsmessaging/outbound/tel%3A%2B17177455076/requests/795bd02c8e343b2dfd673b67dd0ee55a/deliveryInfos"
        }
      }
      
      @message = { "parts"     => 1, 
        "sent"      => "2011-05-13T16:14:50.480+0000", 
        "code"      => "0", 
        "body"      => "Hola from RSpec!", 
        "messageId" => "74ae6147f915eabf87b35b9ea30c5916", 
        "from"      => "17177455076", 
        "to"        => "14153675082", 
        "direction" => "out", 
        "status"    => "success", 
        "created"   => "2011-05-13T16:14:50.480+0000"}
      
      @message_range = [
                        {
                          "parts" => 1,
                          "sent" => "2011-05-13T20:27:56.690+0000",
                          "code" => "-1",
                          "body" => "foobar9446",
                          "messageId" => "d194e91c32de943ae942ad4043b7905b",
                          "from" => "17177455076",
                          "to" => "14155551",
                          "direction" => "out",
                          "status" => "fail",
                          "created" => "2011-05-13T20:27:56.690+0000"
                        },
                        {
                          "parts" => 1,
                          "sent" => "2011-05-13T20:27:53.660+0000",
                          "code" => "-1",
                          "body" => "foobar4374",
                          "messageId" => "4d9237b323618ab164fb6d646882da99",
                          "from" => "17177455076",
                          "to" => "14155551212",
                          "direction" => "out",
                          "status" => "fail",
                          "created" => "2011-05-13T20:27:53.660+0000"
                        }
                       ]
    end
    before(:each) do                      
      stub_request(:get, "https://api.smsified.com/v1/messages/74ae6147f915eabf87b35b9ea30c5916").
        with(:headers => {'Authorization' => [@username, @password]}).
        to_return(:status => ["200", "OK"],
                  :body   => @message.to_json)
      
      stub_request(:get, "https://api.smsified.com/v1/messages?start=2011-05-12&end=2011-05-12").
        with(:headers => {'Authorization' => [@username, @password]}).
        to_return(:status => ["200", "OK"],
                  :headers => {"Content-Type" => "application/json"},
                  :body   => @message_range.to_json)

      stub_request(:get, "https://api.smsified.com/v1/smsmessaging/outbound/#{@sender_address}/requests/795bd02c8e343b2dfd673b67dd0ee55a/deliveryInfos").
        with(:headers => {'Authorization' => [@username, @password]}).
        to_return(:status => ["200", "OK"],
                  :body   => @delivery_status.to_json)
    end
    
    it "Should instantiate a Reporting object" do
      reporting = EventMachine::Smsified::Reporting.new :username => 'smsified_tester_smsified', :password => 'bug.fungus52', :debug => true
      reporting.instance_of?(EventMachine::Smsified::Reporting).should eql true
    end
    
    it "Should get errors if instantiating without all of the right parameters" do
      begin
        EventMachine::Smsified::Reporting.new 'foobar'
      rescue => e
        e.to_s.should eql 'an options Hash is required'
      end
      
      begin
        EventMachine::Smsified::Reporting.new({})
      rescue => e
        e.to_s.should eql ':username required'
      end
      
      begin
        EventMachine::Smsified::Reporting.new(:username => @username)
      rescue => e
        e.to_s.should eql ':password required'
      end
    end
    
    it "should get json by default" do
      response = wrap_and_run(@reporting, :search_sms, 'start=2011-05-12&end=2011-05-12')
      response.http.response_header["CONTENT_TYPE"].should eql "application/json"
    end
    
    it "Should raise an error if no :sender_address specified" do
      begin
        wrap_and_run(@reporting, :delivery_status, 'foobar')
      rescue => e
        e.to_s.should eql 'an options Hash is required'
      end
      
      begin
        @reporting.delivery_status({})
      rescue => e
        e.to_s.should eql ':sender_address is required'
      end
    end
    
    it "Should not raise an error if a :sender_address was specified at instantiation" do
      reporting = EventMachine::Smsified::Reporting.new :username => @username, :password => @password, :debug => true, :sender_address => @sender_address
      delivery_response = wrap_and_run(reporting, :delivery_status, :request_id => '795bd02c8e343b2dfd673b67dd0ee55a')
      delivery_response.data.should == @delivery_status
    end
    
    it "Should retrieve an SMS message" do
      response = wrap_and_run(@reporting, :retrieve_sms, '74ae6147f915eabf87b35b9ea30c5916')
      response.data.should eql @message
    end
    
    it "Should retrieve SMS messages based on a query string" do
      response = wrap_and_run(@reporting, :search_sms, 'start=2011-05-12&end=2011-05-12')
      response.data.should eql @message_range
    end
    
    it "Should send an SMS and get the Delivery status" do
      delivery_response = wrap_and_run(@reporting, :delivery_status, :request_id => '795bd02c8e343b2dfd673b67dd0ee55a', :sender_address => @sender_address)
      delivery_response.data.should == @delivery_status
    end
    
    it "Should let me instantiate a OneAPI object and call reporting methods" do
      one_api = EventMachine::Smsified::OneAPI.new :username => @username, :password => @password, :debug => true
      delivery_response = wrap_and_run(one_api, :delivery_status, :request_id => '795bd02c8e343b2dfd673b67dd0ee55a', :sender_address => @sender_address)
      delivery_response.data.should eql @delivery_status
      
      sms_message = wrap_and_run(one_api, :retrieve_sms, '74ae6147f915eabf87b35b9ea30c5916')
      sms_message.data.should eql @message
    end
  end
  
  describe 'IncomingMessage' do
    it 'Should parse an incoming message from SMSified' do
      json = '{
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
      
      incoming_message = EventMachine::Smsified::IncomingMessage.new json
      incoming_message.date_time.should eql Time.parse '2011-05-11T18:05:54.546Z'
      incoming_message.destination_address.should eql '16575550100'
      incoming_message.message.should eql 'Inbound test'
      incoming_message.message_id.should eql 'ef795d3dac56a62fef3ff1852b0c123a'
      incoming_message.sender_address.should eql '14075550100'
    end
    
    it "Should raise an error if JSON not passed" do
      lambda { EventMachine::Smsified::IncomingMessage.new 'foobar' }.should raise_error(EventMachine::Smsified::MessageError)
    end
    
    it "Should raise an error if a different type than an IncomingMessage is passed" do
      lambda { EventMachine::Smsified::IncomingMessage.new "{ 'foo': 'bar'}" }.should raise_error(EventMachine::Smsified::MessageError)
    end
  end
  describe 'DeliveryInfoNotifaction' do
    it 'Should parse an incoming delivery info notification from SMSified' do
        json = '{ "deliveryInfoNotification": {
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

        del = EventMachine::Smsified::DeliveryInfoNotification.new json
        del.message_id.should eql '2e0b8d79f1084190d50b1c8c1188ad0d'
        del.message.should eql 'Pong'
        del.direction.should eql 'outbound'
        del.delivery_status.should eql 'DeliveredToNetwork'
        del.sender_address.should eql 'tel:+12223334455'
        del.address.should eql 'tel:+11112223344'
        del.created_date_time.should eql Time.parse '2011-11-22T18:19:51.584Z'
      end

      it "Should raise an error if JSON not passed" do
        lambda { EventMachine::Smsified::DeliveryInfoNotification.new 'foobar' }.should raise_error(EventMachine::Smsified::MessageError)
      end
      
      it "Should raise an error if a different type than a DeliveryInfoNotification is passed" do
        lambda { EventMachine::Smsified::DeliveryInfoNotification.new "{ 'foo': 'bar'}" }.should raise_error(EventMachine::Smsified::MessageError)
      end
    end
  end
