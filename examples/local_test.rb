$LOAD_PATH.unshift(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'smsified'
require 'yaml'
require 'eventmachine'

config = YAML.load(File.open('examples/config.yml'))


EM.run do
  Signal.trap("INT") { EM.stop}
  Signal.trap("TRAP") { EM.stop}
  
  puts "Hit CTRL-C to stop"
  puts "=================="
  puts "Server started at " + Time.now.to_s

  smsified = Smsified::OneAPI.new( :username       => config['smsified']['username'],
                                   :password       => config['smsified']['password'],
                                   :sender_address => '12892050134'
                                   )


  puts "Send SMS started " + Time.now.to_s

#  smsified.send_sms(:message => 'Hello there!', 
#               :address        => '19179712649',
               #:notify_url     => config['postbin'],
#               :sender_address => '12892050134') do |http|
#    puts "Response returned " + Time.now.to_s
#    puts http.data
#    puts http.http
#  end

  puts "Reporting Request started " + Time.now.to_s
    smsified.delivery_status(:request_id => 'e7e12f5d6870447a8599bb420e5e9a0d') do |resp|
    puts "Response returned " + Time.now.to_s
    puts resp.data
  end
end
