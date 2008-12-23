$LOAD_PATH.unshift(File.dirname(__FILE__))
$:.unshift File.join(File.dirname(__FILE__), 'vendor', 'sinatra', 'lib')
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'rubygems'
require 'sinatra'
require 'sequel'
require 'pp'
require 'activerecord'
require 'yaml'
require 'earworm'
require 'id3lib'
require 'ostruct'
require File.join(File.dirname(__FILE__), 'lib', 'sinatratunes')
require 'exceptions'
include Rack::Utils

##### Setup enviornament and stuff ####
configure do
  load File.join(File.dirname(__FILE__), 'settings.rb')    
  Settings = OpenStruct.new(@settings)   
  
  ActiveRecord::Base.establish_connection( 
    :adapter => "sqlite3",
    :database => File.join(File.dirname(__FILE__),"db/jukebox_ar.sqlite3" )
  )
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  
  # Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://jukebox.db')  
  
  set :session => true
  set :root => File.dirname(__FILE__)
  set :app_file  => File.join(File.dirname(__FILE__), 'app.rb')
  # set :views  => File.join(File.dirname(__FILE__), 'app/views')
  # set_option :sessions, true
end

configure(:test) do
  Settings.music_folders = [File.join(File.dirname(__FILE__), 'test','fixtures')]
  ActiveRecord::Base.establish_connection( 
    :adapter => "sqlite3",
    :database => File.join( File.dirname(__FILE__),"db/jukebox_test.sqlite3" ) 
  )
  ActiveRecord::Base.logger = Logger.new(File.join( File.dirname(__FILE__),"log", "test.log" ) )
  File.join(File.dirname(__FILE__), 'fixtures', 'Music')
  require 'ruby-debug'
  set :logging => true
  # Settings.music_folders = [File.join(File.dirname(__FILE__), 'test', 'fixtures', 'Music')]
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
## end boot.rb

helpers do
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
  def link_to(name, uri="/#{ escape(name)}", opts={})
    "<a href=\"#{uri}\" #{opts.collect{|k,v| "#{k}=\"#{v}\""}.join(' ')}>#{name}</a>"
  end
  def inspector(thing)
    "<pre>#{pp thing.inspect}</pre>"
  end
  # Return a full path for the given file using the current_library
  # Throw an exception if full_path is requested for a path outside the library (i.e. ../../..)
  def full_path(song_path_within_library)
    expanded_path = File.expand_path(File.join(current_library, song_path_within_library))
    # if !File.split(expanded_path).shift.include?(current_library)
    #      raise SecurityException, "SECURITY: tried to get file outside of library: #{song_path_within_library}"
    #    end
  end
end

get '/' do
  @folders = Dir.glob(current_library+'/*').collect{|d| File.basename d}
  session[:current_directory]  = '/'
  haml :index
end

get '/folders/*' do
  folder_path = File.join(params['splat'])
  # raise InvalidFile, "Tried to play an invalid file: #{folder_path}" if !File.file?(full_path(folder_path))
  session[:current_directory] = File.join(params['splat'])
  @folders = Dir.glob(File.join(current_library, File.join(params['splat']), '/*')).collect{|d|  File.basename(d) if File.directory?(d)}
  @folders.delete_if{|f| f.nil?}
  @songs = Song.find(:all, :conditions=>["path like ?", File.join(current_library, session[:current_directory]) ])
  
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
  pp path
  pp @folders
  @songs = @folders.collect do |file_path|
    Song.find_or_create_from_file(file_path) #if !File.file?(file_path)
  end
  @songs = Song.find(:all, :conditions=>["path like ?", path+"%"])
  pp "songs size = #{@songs.size}"
  haml :folders
end

get '/songs/*' do
  session[:current_directory] = File.join(params['splat'])
  @songs = Song.find(:all, :limit=>200)
  haml :songs
end

get '/playlist/enque/:song_id' do
  Playlist.create if Playlist.count<1
  @playlist = Playlist.first
  @playlist.songs << Song.find(params[:song_id]) if Song.exists?(params[:song_id])
  haml :playlist
end

get '/playlist/' do
  @playlist = Playlist.first
  haml :playlist
end

get '/play/*' do
  play_path = full_path( File.join(params['splat']) )
  puts " playing: #{play_path} |"  
  raise InvalidFile, "Tried to play an invalid file: #{play_path}" if !File.file?(play_path)
  # if params[:splat].length == 1 #and params[:splat].first.match(/d/)
  #    song = Song.find(params[:splat].pop)
  #    send_file song.full_filename
  send_file play_path
end