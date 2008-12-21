require 'rubygems'
$:.unshift File.join(File.dirname(__FILE__), 'vendor', 'sinatra', 'lib')
require 'sinatra'
require File.join(File.dirname(__FILE__), 'lib', 'sinatratunes')

set :public, 'public'
set :views,  'views'

get '/' do
  haml :index
end