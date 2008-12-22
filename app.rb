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
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  # Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://jukebox.db')  
  Settings = OpenStruct.new(
  
    :title => 'stimbletunes',
    :url_base => 'http://localhost:4567/',
    :admin_password => 's3cr3t',
    :admin_cookie_key => 'stimbly_admin',
    :admin_cookie_value => '51d6d4450976913ace58',
    :music_dns_api_key => '2010d2dbda0c091010f12cf97b5d9839',
    :music_folders => ['/Users/fairchild/Music/'])   
    
    set :session => true
    set :root => File.dirname(__FILE__)
    set :app_file  => File.join(File.dirname(__FILE__), 'app.rb')
    # set :views  => File.join(File.dirname(__FILE__), 'app/views')
    # set_option :sessions, true
end

configure(:test) do
  ActiveRecord::Base.establish_connection( 
    :adapter => "sqlite3",
    :database => File.join( File.dirname(__FILE__),"db/jukebox_test.sqlite3" ) 
  )
  require 'ruby-debug'
  set :logging => true
end

## boot.rb
  def require_local_lib(pattern)
    Dir.glob(File.join(File.dirname(__FILE__), pattern)).each {|f| require f }
  end
  def load_local_lib(pattern)
    Dir.glob(File.join(File.dirname(__FILE__), pattern)).each {|f| load f }
  end
  load_local_lib('app/models/**/*.rb')
  require_local_lib('lib/**/*.rb')
  Playlist.create if Playlist.count<1
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
  
  # Retrun a full path for the given file using the current_library
  def library_path(filename)
    File.join(current_library, filename)
  end
end

get '/' do
  @folders = Dir.glob(current_library+'/*').collect{|d| File.basename d}
  session[:current_directory]  = '/'
  haml :index
end

get '/folders/*' do
  session[:current_directory] = File.join(params['splat'])
  @folders = Dir.glob(File.join(current_library, File.join(params['splat']), '/*')).collect{|d|  File.basename(d) if File.directory?(d)}
  @folders.delete_if{|f| f.nil?}
  @songs = Song.find(:all, :conditions=>["path like ?", File.join(current_library,session[:current_directory])+"%"])
  
  haml :folders
end

get '/identify/*' do
  session[:current_directory] = File.join(params['splat'])
  path = File.join(current_library, File.join(params['splat']))
  # Protecect against requests for files that are outside the library
  raise "Invalid Path: #{path}" if path[0...current_library.length] != current_library
  if File.file?(path)
    @folders = [path]
  elsif File.directory?(path)
    @folders = Dir.glob(File.join(path, '*'))
  else
    raise "Identify passed an invalid path: #{path}"
  end
  pp @folders
  @songs = @folders.collect do |file_path|
    Song.find_or_create_from_file(file_path) #if !File.file?(file_path)
  end
  @songs = Song.find(:all, :conditions=>["path like ?", path+"%"])
  pp "songs size = #{pp @songs}"
  haml :folders
end

get '/songs/*' do
  session[:current_directory] = File.join(params['splat'])
  @songs = Song.find(:all, :limit=>200)
  haml :songs
end

get '/que/:id' do
  @playlist = Playlist.first
  @song = Song.find params[:id]
  @playlist.songs << @song
  haml :playlist
end

get '/play/*' do
  pp params
  # if params[:splat].length == 1 #and params[:splat].first.match(/d/)
  #    song = Song.find(params[:splat].pop)
  #    send_file song.full_filename
  if File.file?(File.join(current_library, File.join(params['splat'])) )
    send_file File.join(current_library, File.join(params['splat']))
  end
end