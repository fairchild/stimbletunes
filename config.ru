# To use with thin 
#  thin start -p PORT -R config.ru

require File.join(File.dirname(__FILE__), 'app.rb')
require "rubygems"
require 'rack'
use Rack::CommonLogger

# require 'rack/cache'
# use Rack::Cache,
#   :verbose     => true,
#   :metastore   => "file:#{File.expand_path(File.dirname(__FILE__) + '/meta')}",
#   :entitystore => "file:#{File.expand_path(File.dirname(__FILE__) + '/entity')}"
  
use Rack::Static, :urls => %w(/stylesheets /javascripts /images),
                  :root => File.dirname(__FILE__) + "/public"
use Rack::Session::Cookie
use Rack::Reloader #or tmp/always_restart.txt to reload on each request with passenger
use Rack::ShowExceptions
 # use Rack::Lint #doesn't work with rack


# use Rack::Auth::Basic do |username, password|
#   username == 'admin' && password == 'secret'
# end
  
# log = File.new("sinatra.log", "a")
# STDOUT.reopen(log)
# STDERR.reopen(log)


run StimbleTunes
