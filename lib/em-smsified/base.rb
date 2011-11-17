module EventMachine
  module Smsified
    SMSIFIED_ONEAPI_PUBLIC_URI = 'https://api.smsified.com/v1'
    SMSIFIED_HTTP_HEADERS      = { 'Content-Type' => 'application/x-www-form-urlencoded','Accept'=>'application/json' }

    class Base
      attr_reader :base_uri, :auth, :destination_address, :sender_address

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
        
        @base_uri = options[:base_uri] || SMSIFIED_ONEAPI_PUBLIC_URI
        @auth = { :username => options[:username], :password => options[:password] }
        
        @destination_address = options[:destination_address]
        @sender_address      = options[:sender_address]
      end

      ##
      # HTTP GET's a request
      # @param [required, String] :url to GET from
      #
      def get(url, headers)
        conn = create_connection_object(url)

        http = conn.get(:head => add_authorization_to_header(headers, @auth))

        action = proc do
          response = Response.new(http.response.parsed, http)#.response.raw)
          yield response if block_given?
        end

        http.callback &action
        http.errback &action 
      end

      ##
      # HTTP DELETE's a request
      # @param [required, String] :url to GET from
      #
      def delete(url, headers)
        conn = create_connection_object(url)

        http = conn.delete(:head => add_authorization_to_header(headers, @auth))

        action = proc do
          response = Response.new(http.response.parsed, http)#.response.raw)
          yield response if block_given?
        end

        http.callback &action
        http.errback &action 
      end

      ##
      # HTTP POST's a request
      # @param [required, String] :url to GET from
      #
      def post(url, body, headers)
        conn = create_connection_object(url)

        http = conn.post(:body => body,
                         :head => add_authorization_to_header(headers, @auth))

        action = proc do
          response = Response.new(http.response.parsed, http)#.response.raw)
          yield response if block_given?
        end

        http.callback &action
        http.errback &action 
      end

      private
      def create_connection_object(url)
        conn = EM::HttpRequest.new(SMSIFIED_ONEAPI_PUBLIC_URI + url)
        conn.use JSONify
        return conn
      end

      def add_authorization_to_header(headers, auth)
        return headers.merge({'Authorization' => [auth[:username], auth[:password]]})
      end
    end
  end
end
