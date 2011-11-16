module Smsified
  class ResponseProxy
    attr_reader :raw, :parsed

    def initialize(parsed, raw)
      @parsed = parsed
      @raw = raw
    end
  end

  class JSONify
    def response(resp)
      resp.response = ResponseProxy.new(Yajl::Parser.parse(resp.response), resp.response)
    end
  end

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
