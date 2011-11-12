module Smsified
  module SubscriptionsModule
    ##
    # Creates an inbound subscription
    # 
    # @param [required, String] destination_address to subscribe to
    # @param [required, Hash] params to send an sms
    # @option params [optional, String] :notify_url to send callbacks to
    # @option params [optional, String] :client_correlator to update
    # @option params [optional, String] :callback_data to update
    # @return [Object] A Response Object with http and data instance methods
    # @param [required, String] notify_url to send callbacks to
    # @return [Object] A Response Object with http and data instance methods
    # @example
    #   subscriptions.create_inbound_subscription('tel:+14155551212', :notify_url => 'http://foobar.com')
    def create_inbound_subscription(destination_address, options)
      query = options.merge({ :destination_address => destination_address })
      
      Response.new post("/smsmessaging/inbound/subscriptions", 
                        camelcase_keys(query),
                        @auth,
                        SMSIFIED_HTTP_HEADERS
                        )

    end
    
    ##
    # Creates an outbound subscription
    # 
    # @param [required, String] sender_address to subscribe to
    # @option params [optional, String] :notify_url to send callbacks to
    # @option params [optional, String] :client_correlator to update
    # @option params [optional, String] :callback_data to update
    # @return [Object] A Response Object with http and data instance methods
    # @example
    #   subscriptions.create_outbound_subscription('tel:+14155551212', :notify_url => 'http://foobar.com')    
    def create_outbound_subscription(sender_address, options)
      Response.new post("/smsmessaging/outbound/#{sender_address}/subscriptions", 
                        build_query_string(options),
                        @auth,
                        SMSIFIED_HTTP_HEADERS
                        )
    end
    
    ##
    # Deletes an inbound subscription
    # 
    # @param [required, String] subscription_id to delete
    # @return [Object] A Response Object with http and data instance methods
    # @example
    #   subscriptions.delete_inbound_subscription('89edd71c1c7f3d349f9a3a4d5d2d410c')
    def delete_inbound_subscription(subscription_id)
      Response.new delete("/smsmessaging/inbound/subscriptions/#{subscription_id}",  @auth,SMSIFIED_HTTP_HEADERS)
    end
    
    ##
    # Deletes an outbound subscription
    # 
    # @param [required, String] subscription_id to delete
    # @return [Object] A Response Object with http and data instance methods
    # @example
    #   subscriptions.delete_outbound_subscription('89edd71c1c7f3d349f9a3a4d5d2d410c')
    def delete_outbound_subscription(sender_address)
      Response.new delete("/smsmessaging/outbound/subscriptions/#{sender_address}", @auth,SMSIFIED_HTTP_HEADERS)
    end
    
    ##
    # Fetches the inbound subscriptions
    #
    # @param [required, String] destination_address to fetch the subscriptions for
    # @return [Object] A Response Object with http and data instance methods
    # @example
    #   subscriptions.inbound_subscriptions('tel:+14155551212')
    def inbound_subscriptions(destination_address)
      Response.new get("/smsmessaging/inbound/subscriptions?destinationAddress=#{destination_address}",  @auth, SMSIFIED_HTTP_HEADERS)
    end

    ##
    # Fetches the outbound subscriptions
    #
    # @param [required, String] sender_address to fetch the subscriptions for
    # @return [Object] A Response Object with http and data instance methods
    # @example
    #   subscriptions.outbound_subscriptions('tel:+14155551212')
    def outbound_subscriptions(sender_address)
      Response.new get("/smsmessaging/outbound/subscriptions?senderAddress=#{sender_address}", @auth,SMSIFIED_HTTP_HEADERS)
    end
    
    ##
    # Updates an inbound subscription
    # 
    # @option params [required, String] subscription_id updating
    # @param [required, Hash] params to update the inbound subscription with
    # @option params [optional, String] :notify_url to send callbacks to
    # @option params [optional, String] :client_correlator to update
    # @option params [optional, String] :callback_data to update
    # @return [Object] A Response Object with http and data instance methods
    # @example
    #   subscriptions.update_inbound_subscription('89edd71c1c7f3d349f9a3a4d5d2d410c', :notify_url => 'foobar')
    def update_inbound_subscription(subscription_id, options)
      Response.new post("/smsmessaging/inbound/subscriptions/#{subscription_id}", 
                        build_query_string(options),
                        @auth,
                        SMSIFIED_HTTP_HEADERS
                        )
    end
    
    ##
    # Updates an outbound subscription
    # 
    # @option params [required, String] sender_address updating
    # @param [required, Hash] params to update the outbound subscription with
    # @option params [optional, String] :notify_url to send callbacks to
    # @option params [optional, String] :client_correlator to update
    # @option params [optional, String] :callback_data to update
    # @return [Object] A Response Object with http and data instance methods
    # @example
    #   subscriptions.update_outbound_subscription('tel:+14155551212', :notify_url => 'foobar')
    def update_outbound_subscription(sender_address, options)
      Response.new post("/smsmessaging/outbound/#{sender_address}/subscriptions",                                   build_query_string(options), 
                        @auth,
                        SMSIFIED_HTTP_HEADERS
                        )
    end
  end

  class Subscriptions < Base
    include Helpers
    include SubscriptionsModule        
    ##
    # Intantiate a new class to work with subscriptions
    # 
    # @example
    #   subscription = Subscription.new :username => 'user', :password => '123'
    def initialize(options)
      super(options)
    end
  end
end
