module Smsified
  class OneAPI < Base
    include Helpers
    include SubscriptionsModule
    include ReportingModule

    ##
    # @example 
    #   one_api = OneAPI.new :username => 'user', :password => '123'
    def initialize(options)
      super(options)
    end
    
    ##
    # Send an SMS to one or more addresses
    #
    # @param [required, Hash] params to send an sms
    # @option params [required, String] :address to send the SMS to
    # @option params [required, String] :message to send with the SMS
    # @option params [optional, String] :sender_address to use with subscriptions, required if not provided on initialization of OneAPI
    # @option params [optional, String] :notify_url to send callbacks to
    # @return [Object] A Response Object with http and data instance methods
    # @raise [ArgumentError] if :sender_address is not passed as an option when not passed on object creation
    # @raise [ArgumentError] if :address is not provided as an option
    # @raise [ArgumentError] if :message is not provided as an option
    # @example 
    #   one_api.send_sms :address => '14155551212', :message => 'Hi there!', :sender_address => '13035551212'
    #   one_api.send_sms :address => ['14155551212', '13035551212'], :message => 'Hi there!', :sender_address => '13035551212'
    def send_sms(options, &blk)
      raise ArgumentError, 'an options Hash is required' if !options.instance_of?(Hash)
      raise ArgumentError, ':sender_address is required' if options[:sender_address].nil? && @sender_address.nil?
      raise ArgumentError, ':address is required' if options[:address].nil?
      raise ArgumentError, ':message is required' if options[:message].nil?
      
      options[:sender_address] = options[:sender_address] || @sender_address
      query_options = options.clone
      query_options.delete(:sender_address)
      query_options = camelcase_keys(query_options)

      post("/smsmessaging/outbound/#{options[:sender_address]}/requests",
                                   build_query_string(query_options),
                                   @auth,
                                   SMSIFIED_HTTP_HEADERS, &blk)
    end
  end
end
