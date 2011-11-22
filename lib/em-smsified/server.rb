module EventMachine
  module Smsified
    ##
    # Does the actual handling of the incoming notifications from SMSified. Factored out to ease in testing.
    #
    module ServerHandler
      ##
      # Sets the block to call when an incoming message arrives
      #
      def on_incoming_message(&blk)
        @on_incoming_message = blk
      end
      
      ##
      # Sets the block to call when a delivery notification arrives
      #
      def on_delivery_notification(&blk)
        @on_delivery_notification = blk
      end

      ##
      # Sets the block to call when an unknown message arrives
      #
      def on_unknown(&blk)
        @on_unknown = blk
      end      

      def trigger_on_incoming_message(msg)
        @on_incoming_message.call(msg) if @on_incoming_message
      end

      def trigger_on_delivery_notification(msg)
        @on_delivery_notification.call(msg) if @on_delivery_notification
      end

      def trigger_on_unknown(request)
        @on_unknown.call(request) if @on_unknown
      end


      ##
      # Inspects the method and contents of the incoming request and handles it.
      # @param [required, String] the HTTP method of the request
      # @param [optional, String] the POST'ed content of the request
      # @return [bool] true if request was handled, false if not
      def handle(method, content)
        if is_post? method
          return handle_incoming_message(content) || handle_delivery_notification(content) || handle_unknown(content)
        end
        return false
      end

      private

      def is_post?(method)
        return method == "POST"
      end

      def handle_unknown(content)
        trigger_on_unknown(content)
        return true
      end

      def handle_delivery_notification(content)
        begin
          msg = EventMachine::Smsified::DeliveryInfoNotification.new(content)
          trigger_on_delivery_notification(msg)
          return true
        rescue
        end
        return false
      end

      def handle_incoming_message(content)
        begin
          msg = EventMachine::Smsified::IncomingMessage.new(content)
          trigger_on_incoming_message(msg)
          return true
        rescue
        end
        return false
      end

    end

    ##
    # Allows you to set up a server for incoming SMSified callbacks.
    # @example
    #  see examples/pong_server.rb
    class Server < EM::Connection
      include EM::HttpServer, ServerHandler

      def post_init
        super
        no_environment_strings
      end

      ##
      # Does processing of incoming HTTP requests.
      #
      def process_http_request
        # the http request details are available via the following instance variables:
        #   @http_protocol
        #   @http_request_method
        #   @http_cookie
        #   @http_if_none_match
        #   @http_content_type
        #   @http_path_info
        #   @http_request_uri
        #   @http_query_string
        #   @http_post_content
        #   @http_headers
        puts "Request received " + Time.now.to_s
        
        handle(@http_request_method, @http_post_content)

        send_ok()
      end

      private
      def send_ok
        response = EM::DelegatedHttpResponse.new(self)
        response.status = 200
        response.send_response        
      end
    end
  end
end
