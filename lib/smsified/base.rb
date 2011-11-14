module Smsified
  SMSIFIED_ONEAPI_PUBLIC_URI = 'https://api.smsified.com/v1'
  SMSIFIED_HTTP_HEADERS      = { 'Content-Type' => 'application/x-www-form-urlencoded','Accept'=>'application/json' }

class Base
  include HTTParty
  format :json

    ##
    # Intantiate a new class to work with OneAPI
    # 
    # @param [required, Hash] params to create the user
    # @option params [required, String] :username username to authenticate with
    # @option params [required, String] :password to authenticate with
    # @option params [optional, String] :base_uri of an alternative location of SMSified
    # @option params [optional, String] :destination_address to use with subscriptions
    # @option params [optional, String] :sender_address to use with subscriptions
    # @option params [optional, Boolean] :debug to turn on the HTTparty debugging to stdout
    # @raise [ArgumentError] if :username is not passed as an option
    # @raise [ArgumentError] if :password is not passed as an option
    def initialize(options)
      raise ArgumentError, 'an options Hash is required' if !options.instance_of?(Hash)
      raise ArgumentError, ':username required' if options[:username].nil?
      raise ArgumentError, ':password required' if options[:password].nil?
      
      self.class.debug_output $stdout if options[:debug]
      self.class.base_uri options[:base_uri] || SMSIFIED_ONEAPI_PUBLIC_URI
      @auth = { :username => options[:username], :password => options[:password] }
      
      @destination_address = options[:destination_address]
      @sender_address      = options[:sender_address]
    end


  def get(url, auth, headers)
    return Response.new self.class.get(url, 
                          :basic_auth => auth, 
                          :headers => headers)
  end

  def post(url, body, auth, headers)
    return Response.new self.class.post(url,
                                   :body       => body,
                                   :basic_auth => auth,
                                   :headers    => headers)
  end

  def delete(url, auth, headers)
    return Response.new self.class.delete(url, 
                             :basic_auth => auth, 
                             :headers    => headers)
  end
end
end
