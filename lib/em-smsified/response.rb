module EventMachine
  module Smsified

    ##
    # Functions as a proxy on the EventMachine HTTP Response so you can get the raw and parsed response
    #
    class ResponseProxy
      attr_reader :raw, :parsed

      def initialize(parsed, raw)
        @parsed = parsed
        @raw = raw
      end
    end

    ##
    # Used by em-http-request to parse the JSON coming in
    #
    class JSONify
      def response(resp)
        resp.response = ResponseProxy.new(Yajl::Parser.parse(resp.response), resp.response)
      end
    end

    ##
    # The result object from the API. Used to access the parsed and raw HTTP response.
    #
    class Response
      attr_reader :data, :http
      
      ##
      # Provides the standard response for the library
      #
      # @param [Object] an HTTParty result object
      def initialize(parsed, raw)
        @data = parsed
        @http = raw
      end
    end
  end
end
