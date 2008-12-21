require 'rubygems'
$:.unshift File.join(File.dirname(__FILE__), 'vendor', 'sinatra', 'lib')
require 'sinatra'
require File.join(File.dirname(__FILE__), 'lib', 'sinatratunes')
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'rubygems'
require 'sinatra'
require 'sequel'
require 'pp'
require 'activerecord'
require 'yaml'
require 'earworm'
require 'ostruct'

include Rack::Utils

##### Setup enviornament and stuff ####

configure do  
  ActiveRecord::Base.establish_connection( 
    :adapter => "sqlite3",
    :database => File.join(File.dirname(__FILE__),"db/jukebox_ar.sqlite3" )
  )
  # Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://jukebox.db')  
  Settings = OpenStruct.new(
  
    :title => 'stimbletunes',
    :url_base => 'http://localhost:4567/',
    :admin_password => 's3cr3t',
    :admin_cookie_key => 'stimbly_admin',
    :admin_cookie_value => '51d6d4450976913ace58',
    :music_dns_api_key => '2010d2dbda0c091010f12cf97b5d9839',
    :music_folders => ['/Users/fairchild/Music/Mogwai'])   
    set :session => true
end

configure(:test) do
  ActiveRecord::Base.establish_connection( 
    :adapter => "sqlite3",
    :database => File.join( File.dirname(__FILE__),"db/jukebox_test.sqlite3" ) 
  )
  set :root => File.dirname(__FILE__)
  set :app_file  => File.join(File.dirname(__FILE__), 'app.rb')
  set :views  => File.join(File.dirname(__FILE__), 'app/views')
  require 'ruby-debug'
  set :logging => true
end

set_option :sessions, true

## boot.rb
  def require_local_lib(pattern)
    Dir.glob(File.join(File.dirname(__FILE__), pattern)).each {|f| require f }
  end
  def load_local_lib(pattern)
    Dir.glob(File.join(File.dirname(__FILE__), pattern)).each {|f| load f }
  end
  load_local_lib('app/models/**/*.rb')
  require_local_lib('lib/**/*.rb')
## end boot.rb

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  def admin?
    request.cookies[Settings.admin_cookie_key] == Settings.admin_cookie_value
  end
  def auth
    stop [ 401, 'Not authorized' ] unless true or admin?
  end
  def current_library
    Settings.music_folders.first
  end
  def song_file_path(folder, filename)
    File.join(current_library, folder, filename)
  end
  def link_to(name, uri="/#{ escape(name)}")
    "<a href=\"#{uri}\">#{name}</a>"
  end
  def inspector(thing)
    "<pre>#{pp thing.inspect}</pre>"
  end
end

get '/' do
  @folders = Dir.glob(current_library+'/*').collect{|d| File.basename d}
  session[:current_directory]  = '/'
  session[:last_directory]  = '/'
  
  haml :index
end

get '/folders/*' do
  session[:current_directory] = File.join(params['splat'])
  # 
  # pp folder
  # pp "\n *** looking for : #{unescape(folder)}, previously was in #{session.inspect}"
  # pp session
  @folders = Dir.glob(File.join(current_library, File.join(params['splat']), '/*')).collect{|d|  File.basename(d)}
  haml :index
end