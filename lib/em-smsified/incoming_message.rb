module EventMachine
  module Smsified

    class MessageError < StandardError; end

    class DeliveryInfoNotification
      attr_reader :delivery_status, :code, :message_id, :sender_address, :address, :created_date_time, :sent_date_time, :parts, :direction, :message

      ##
      # Intantiate a new object to provide convenience methods on a Delivery Info Notification. 
      # Note: This class only pulls the first delivery info object from the notification. There can be more as per the spec.
      # http://smsified.com/sms-api-documentation/sending#checking_status
      # 
      # @param [required, String] valid JSON for an Delivery Info Notifcation to be parsed
      # @return [Object] the parsed delivery info notification
      # @raise [ArgumentError] if json is not valid JSON or an Delivery Info Notifcation type
      # @example 
      #   del = DeliveryInfoNotification.new(json)
      #   puts del.message # foobar
      def initialize(json)
        begin
          @json = JSON.parse json
          contents = @json['deliveryInfoNotification']['deliveryInfo']

          @delivery_status = contents['deliveryStatus']
          @code = contents['code']
          @message_id = contents['messageId']
          @sender_address = contents['senderAddress']
          @address = contents['address']
          @created_date_time = Time.parse contents['createdDateTime']
          @sent_date_time = Time.parse contents['sentDateTime']
          @parts = contents['parts']
          @direction = contents['direction']
          @message = contents['message']
        rescue => error
          raise EventMachine::Smsified::MessageError, "Not valid JSON or DeliveryInfoNotification"
        end          
      end
    end
    class IncomingMessage
      attr_reader :date_time, :destination_address, :message, :message_id, :sender_address, :json
      
      ##
      # Intantiate a new object to provide convenience methods on an Incoming Message
      # http://www.smsified.com/sms-api-documentation/receiving
      # 
      # @param [required, String] valid JSON for an Incoming Message to be parsed
      # @return [Object] the parsed incoming message
      # @raise [ArgumentError] if json is not valid JSON or an Incoming Message type
      # @example 
      #   incoming_message = IncomingMessage.new(json)
      #   puts incoming_message.message # foobar
      def initialize(json)
        begin
          @json                = JSON.parse json
          
          contents             = @json['inboundSMSMessageNotification']['inboundSMSMessage']
          
          @date_time           = Time.parse contents['dateTime']
          @destination_address = contents['destinationAddress']
          @message             = contents['message']
          @message_id          = contents['messageId']
          @sender_address      = contents['senderAddress']
        rescue => error
          raise EventMachine::Smsified::MessageError, "Not valid JSON or IncomingMessage"
        end
      end
    end
  end
end
