$LOAD_PATH.unshift(File.dirname(__FILE__))
$:.unshift File.join(File.dirname(__FILE__), 'vendor', 'sinatra', 'lib')
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'rubygems'
require 'sinatra'
require 'sequel'
require 'pp'
require 'activerecord'
require 'yaml'
require 'ostruct'
require File.join(File.dirname(__FILE__), 'lib', 'sinatratunes')
require 'exceptions'

include Rack::Utils

use Rack::Auth::Basic do |username, password|
  username == 'admin' && password == 'secret'
end

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
  
  set :sessions => true
  set :root => File.dirname(__FILE__)
  set :app_file  => File.join(File.dirname(__FILE__), 'app.rb')
  # set :views  => File.join(File.dirname(__FILE__), 'app/views')
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
    stop [ 401, 'Not authorized' ] unless admin?
  end
  def current_library
    session[:current_library] || Settings.music_folders.last
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
  def link_to_song(song)
    "<a href=\"/play/#{escape(song.full_path)}\" rel=\"/play/#{escape(song.full_path)}\" >#{song}</a>"
  end
  def scan_folder(base_path)
    puts "SCANNING: #{base_path}"
    if File.directory?(base_path)
      Dir.foreach(base_path) do |dir|
        file_path = File.join(base_path, dir)
        next if ['.DS_Store', '.', '..'].include?(dir)
        puts "dir #{File.directory?(file_path)} = #{file_path}"
        
        Song.find_or_create_from_file(file_path, true) if File.file?(file_path)
        if File.directory?(file_path)
          puts "scan #{file_path}"
          scan_folder(file_path) 
        end
      end
    else
      raise "passed an invalid path: #{path}"
    end
    # files.each do |file_path|
    #   Song.find_or_create_from_file(file_path, true) if File.file?(file_path)
    # end
  end
end



get '/' do
  @folders = Dir.glob(current_library+'/*').collect{|d| File.basename d}
  session[:current_directory]  = '/'
  haml :folders
end

get '/login' do
  haml :login
end
post '/login' do
  set_cookie(Settings.admin_cookie_key, Settings.admin_cookie_value) if params[:password] == Settings.admin_password
	redirect '/'	
end
get '/logout' do
  request.cookies[Settings.admin_cookie_key] = nil
	redirect '/login'	
end

get '/folders/*' do
  folder_path = File.join(params['splat'])
  # raise InvalidFile, "Tried to display an invalid folder: #{folder_path}" if !File.exists?(full_path(folder_path))
  session[:current_directory] = File.join(params['splat'])
  @folders = Dir.glob(File.join(current_library, File.join(folder_path, '/*'))).collect{|d|  File.basename(d) if File.directory?(d)}
  @folders.delete_if{|f| f.nil?}
  @songs = Song.find(:all, :conditions=>["path like ?", File.join(current_library, session[:current_directory]) ])
  haml :folders
end

get '/identify/*' do  
  session[:current_directory] = File.join(params['splat'])
  path = File.join(current_library, File.join(params['splat']))
  #raise SecurityException, "Invalid Path: #{path[0...current_library.length]}" if !Settings.music_folders.grep(path[0...current_library.length]).blank?
  scan_folder(path)
  @songs = Song.find(:all, :limit=>50, :conditions=>["path like ?", path+"%"])
  haml :folders
end

get '/songs/*' do
  session[:current_directory] = File.join(params['splat'])
  @songs = Song.find(:all, :limit=>200)
  haml :folders
end

get '/playlist/enque/:song_id' do
  Playlist.create if Playlist.count<1
  @playlist = session[:current_playlist] || Playlist.first
  @playlist.songs << Song.find(params[:song_id]) if Song.exists?(params[:song_id])
  if request.xhr?
    @playlist.songs.size
  else
    redirect '/playlist', 303  #use a 303 code to force reset method to GET
  end
end

get '/playlist/remove/:playlist_song_id' do
  pp request
  @playlist = session[:current_playlist] || Playlist.first
  @playlist.songs.delete(@playlist.songs.find(params[:playlist_song_id]))
  if request.xhr?
    @playlist.songs.size
    puts "it was xhr"
  else
    puts "file removed, not thru ajax"
    # redirect '/playlist'  #use a 303 code to force reset method to GET
  end
end

get '/playlist' do
  @playlist = Playlist.first
  haml :playlist # :layout => :playlist_layout
end

get '/libraries/*' do
  new_media_library = File.join('/', params[:splat])
  if params['splat'].first != ''
    puts "changing current_library from #{current_library}"
    # current_library = File.join('/', params[:splat])  #TODO why does this fail?
    if Settings.music_folders.include?(new_media_library)
      session[:current_library] = File.join('/', params[:splat])
    else
      raise SecurityException, "tried to change current_library to directory outside of settings: #{File.join('/', params[:splat])}"
    end
  end
  @libraries = Settings.music_folders
  haml :libraries
end

get '/play/*' do
  # if params[:splat].first.match(/d/)
  #    song = Song.find(params[:splat].pop)
  song = Song.find_by_full_path( File.join(params['splat']) )
  # song.increment_play_count
  return false if song.blank?
  raise InvalidFile, "Tried to play an invalid file: #{song.full_path}" if !File.file?(song.full_path)
  puts " -> playing: #{song.full_path} ->\n"  
  send_file song.full_path
end
