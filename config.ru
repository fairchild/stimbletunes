# To use with thin 
#  thin start -p PORT -R config.ru

require File.join(File.dirname(__FILE__), 'app.rb')

require 'rack/cache'
use Rack::Cache,
  :verbose     => true,
  :metastore   => "file:#{File.expand_path(File.dirname(__FILE__) + '/meta')}",
  :entitystore => "file:#{File.expand_path(File.dirname(__FILE__) + '/entity')}"


set :app_file, File.expand_path(File.dirname(__FILE__) + '/app.rb')
set :public,   File.expand_path(File.dirname(__FILE__) + '/public')
set :views,    File.expand_path(File.dirname(__FILE__) + '/views')
set :env,      :production

log = File.new("sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)


disable :run, :reload

run Sinatra.application
