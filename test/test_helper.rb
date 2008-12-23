require 'rubygems'
require 'redgreen'
$:.unshift File.join(File.dirname(__FILE__), '..', 'vendor', 'sinatra', 'lib')
require 'sinatra'
require 'sinatra/test/unit'
require 'shoulda'
require File.join(File.dirname(__FILE__), '..', 'app.rb')
require File.join(File.dirname(__FILE__), '../', 'exceptions.rb')

def current_library
  File.expand_path(File.join(Sinatra.options.root, 'test', 'fixtures', 'Music'))
  # File.join("~/Users/fairchild/Sites/sinatratunes",  'fixtures', 'Music')
end
def test_mp3_relative_file_path
  File.join('Mogwai', 'Rock Action', '06. Robot Chant.mp3')
end
def test_mp3_full_file_path
  File.join(current_library, 'Mogwai', 'Rock Action', '06. Robot Chant.mp3')
end
def full_path(song_path_within_library)
  expanded_path = File.join(current_library, song_path_within_library)
end
