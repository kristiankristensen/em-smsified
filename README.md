em-smsified
========

SMSified is a simple API for sending and receiving text messages using regular phone numbers or short codes. SMSified uses a simple REST interface based on the GSMA OneAPI standard and is backed by Voxeo - the worlds largest communications cloud. Ruby lib for consuming the SMSified OneAPI.

This is a Ruby gem for consuming the SMSified OneAPI with EventMachine.

This library was originally released by Tropo at http://github.com/smsified/smsified-ruby by Jason Goecke and John Dyer. It has been modified to work in the context of EventMachine by Kristian Kristensen.

Installation
------------

	gem install em-smsified
 
Example
-------

All of the API methods take an anonymous block which is the method called when the server returns. It yields the response so you can access the result of executing the API operation. The examples below illustrates this. If you don't care about the result of the operation, don't pass a block.

Send an SMS:

	require 'rubygems'
	require 'eventmachine'
	require 'em-smsified'

	oneapi = EventMachine::Smsified::OneAPI.new(:username => 'user', :password => 'bug.fungus24')

	EM.run do
	       oneapi.send_sms :address => '14155551212', :message => 'Hi there!', :sender_address => '13035551212'
	end


Find a subscription:

	require 'rubygems'
	require 'eventmachine'
	require 'em-smsified'

	subscriptions = EventMachine::Smsified::Subscriptions.new(:username => 'user', :password => 'bug.fungus24')

	EM.run do
		subscriptions.inbound_subscriptions('17177455076')
	end

Parse the JSON for a callback Incoming Message:

    require 'rubygems'
    require 'em-smsified'

    # Also require your favorite web framework such as Rails or Sinatra
    incoming_message = EventMachine::Smsified::IncomingMessage.new json_body
    puts incoming_message.date_time           # Wed May 11 18:05:54 UTC 2011
    puts incoming_message.destination_address # '16575550100'
    puts incoming_message.message             # 'Inbound test'
    puts incoming_message.message_id          # 'ef795d3dac56a62fef3ff1852b0c123a'
    puts incoming_message.sender_address      # '14075550100'

Documentation
-------------

May be found at http://kristiankristensen.github.com/em-smsified & http://smsified.com.

License
-------

MIT - See LICENSE.txt