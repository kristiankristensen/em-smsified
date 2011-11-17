##
# Run this file from the smsified root dir, ie. :
# ruby examples/sending_and_subscribing.rb
#
# Remember to copy config.yml.sample to config.yml and insert your SMSified credentials
# Also you need to change the "sender_address" parameter below to your registered SMSified number, and the "receiver_address" to the mobile number you want to send texts to.
#

$LOAD_PATH.unshift(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'smsified'
require 'yaml'
require 'eventmachine'

config = YAML.load(File.open('examples/config.yml'))

smsified = EventMachine::Smsified::OneAPI.new(:username => config['smsified']['username'],
                                              :password => config['smsified']['password'])

sender_address = '14157044517'
receiver_address = '17177455076'

EM.run do
  Signal.trap("INT") { EM.stop}
  Signal.trap("TRAP") { EM.stop}
  
  puts "Hit CTRL-C to stop"
  puts "=================="
  puts "Server started at " + Time.now.to_s
  
  
  puts "Send an SMS to one address " + Time.now.to_s
  smsified.send_sms( :message        => 'Hello there!', 
                     :address        => receiver_address,
                     :notify_url     => config['postbin'],
                     :sender_address => sender_address) do |result|
    puts result.data.inspect
    puts result.http.inspect
  end     
  
  puts "Send an SMS to multiple addresses" + Time.now.to_s
  smsified.send_sms( :message        => 'Hello there, multiple recipients!', 
                     :address        => [receiver_address, receiver_address],
                     :notify_url     => config['postbin'],
                     :sender_address => sender_address) do |result|
    puts "Response returned " + Time.now.to_s
    puts result.data.inspect
    puts result.http.inspect
  end

  puts "Create in inbound subscription" + Time.now.to_s
  smsified.create_inbound_subscription( sender_address, 
                                        :notify_url => config['postbin']
                                       ) do |result|
    puts "Response returned " + Time.now.to_s
    puts result.data.inspect
    puts result.http.inspect
  end

  puts "Get some of your sent SMS details" + Time.now.to_s
  smsified.search_sms( 'start=2011-11-14&end=2011-11-15') do |result|
    puts "Response returned " + Time.now.to_s
    puts result.data.inspect
    puts result.data.inspect
  end
end                                


