$LOAD_PATH.unshift(File.dirname(__FILE__))
%w(
 cgi 
 time
json
eventmachine
em-http-request
evma_httpserver
yajl
 em-smsified/helpers 
 em-smsified/response 
 em-smsified/base
 em-smsified/server
 em-smsified/subscriptions 
 em-smsified/reporting 
 em-smsified/oneapi 
 em-smsified/incoming_message
).each { |lib| require lib }
