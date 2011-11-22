module EventMachine
  module Smsified
    class Server < EM::Connection
      include EM::HttpServer

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


      def post_init
        super
        no_environment_strings
      end

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

        if (is_post?)
          if (is_incoming_message || is_delivery_notification)
            send_ok()
            return
          else
            trigger_on_unknown(@http_post_content)
          end
        end

        send_ok()
      end

      private

      def is_delivery_notification
          begin
            msg = EventMachine::Smsified::DeliveryInfoNotification.new(@http_post_content)
            trigger_on_delivery_notification(msg)
            return true
          rescue
          end
        return false
      end

      def is_incoming_message
          begin
            msg = EventMachine::Smsified::IncomingMessage.new(@http_post_content)
            trigger_on_incoming_message(msg)
            return true
          rescue
          end
        return false
      end

      def is_post?
        return @http_request_method == "POST"
      end

      def send_ok
        response = EM::DelegatedHttpResponse.new(self)
        response.status = 200
        response.send_response        
      end
    end
  end
end
