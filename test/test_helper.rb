require 'rubygems'
$:.unshift File.join(File.dirname(__FILE__), '..', 'vendor', 'sinatra', 'lib')
require 'sinatra'
require 'sinatra/test/unit'
require 'shoulda'
require File.join(File.dirname(__FILE__), '..', 'app.rb')
