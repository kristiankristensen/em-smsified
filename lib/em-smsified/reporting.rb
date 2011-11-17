module EventMachine
  module Smsified
    module ReportingModule    
      ##
      # Get the delivery status of an outstanding SMS request
      #
      # @param [required, Hash] params to get the delivery status
      # @option params [required, String] :request_id to fetch the status for
      # @option params [optional, String] :sender_address used to send the SMS, required if not provided on initialization of OneAPI
      # @return [Object] A Response Object with http and data instance methods
      # @raise [ArgumentError] of :sender_address is not passed here when not passed on instantiating the object
      # @example
      #   one_api.delivery_status :request_id => 'f359193765f6a3149ca76a4508e21234', :sender_address => '14155551212'
      def delivery_status(options, &blk)
        raise ArgumentError, 'an options Hash is required' if !options.instance_of?(Hash)
        raise ArgumentError, ':sender_address is required' if options[:sender_address].nil? && @sender_address.nil?
        
        options[:sender_address] = options[:sender_address] || @sender_address

        get("/smsmessaging/outbound/#{options[:sender_address]}/requests/#{options[:request_id]}/deliveryInfos", SMSIFIED_HTTP_HEADERS, &blk)
      end
      
      ##
      # Retrieve a single SMS
      # 
      # @param [required, String] message_id of the message to retrieve
      # @return [Object] A Response Object with http and data instance methods
      # @example
      #   reporting.retrieve_sms '74ae6147f915eabf87b35b9ea30c5916'
      def retrieve_sms(message_id, &blk)
        get("/messages/#{message_id}", SMSIFIED_HTTP_HEADERS, &blk)
      end
      
      ##
      # Retrieve multiple SMS messages based on a query string
      # 
      # @param [required, String] query_string to search SMS messages for
      # @return [Object] A Response Object with http and data instance methods
      # @example
      #   reporting.search_sms 'start=2011-02-14&end=2011-02-15'
      def search_sms(query_string, &blk)
        get("/messages?#{query_string}", SMSIFIED_HTTP_HEADERS, &blk)
      end
    end


    class Reporting < Base
      include ReportingModule
      ##
      # Intantiate a new class to work with reporting
      # 
      # @example
      #   subscription = Subscription.new :username => 'user', :password => '123'
      def initialize(options)
        super(options)
      end
    end
  end
end
