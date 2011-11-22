$LOAD_PATH.unshift(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'yaml'
require 'em-smsified'
require 'eventmachine'
require 'evma_httpserver'

config = YAML.load(File.open('examples/config.yml'))

smsified = EventMachine::Smsified::OneAPI.new(:username => config['smsified']['username'],
                                              :password => config['smsified']['password'])

EM.run do
  Signal.trap("INT") { EM.stop }

  Signal.trap("TRAP") { EM.stop }
    
    puts "Hit CTRL-C to stop"
    puts "=================="
    puts "Server started at " + Time.now.to_s

    puts "Starting incoming SMSified callback server"

    EM.start_server '0.0.0.0', 8080, EventMachine::Smsified::Server do |s|
    s.on_unknown do |content| 
      puts "Unknown received (#{content})"
    end

    s.on_delivery_notification do |msg|
      puts "Delivery Notification " + Time.now.to_s
      puts msg.inspect
    end
      
    s.on_incoming_message do |msg|
      puts "Message received " + Time.now.to_s
      puts "#{msg.sender_address} says '#{msg.message}' to #{msg.destination_address}"
      puts msg.inspect
      smsified.send_sms( :message        => 'Pong', 
                         :address        => msg.sender_address,
                         :notify_url     => config['postbin'],
                         :sender_address => msg.destination_address) do |result|
        puts "Pong sent " + Time.now.to_s
        puts result.data.inspect
      end     
    end
  end
end
