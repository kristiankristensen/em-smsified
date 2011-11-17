$LOAD_PATH.unshift(File.dirname(__FILE__))
%w(
 cgi 
 time
eventmachine
em-http-request
yajl
 smsified/helpers 
 smsified/response 
 smsified/base
 smsified/subscriptions 
 smsified/reporting 
 smsified/oneapi 
 smsified/incoming_message
).each { |lib| require lib }
