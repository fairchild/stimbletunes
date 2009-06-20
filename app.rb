$LOAD_PATH.unshift(File.dirname(__FILE__))
$:.unshift File.join(File.dirname(__FILE__), 'vendor', 'sinatra', 'lib')
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'rubygems'
require 'ruby-debug'
require 'sinatra/base'
require 'sequel'
require 'pp'
require 'activerecord'
require 'yaml'
require 'ostruct'
require File.join(File.dirname(__FILE__), 'lib', 'sinatratunes')
require 'exceptions'
require "lib/sinatra/stimble_extensions"

def require_local_lib(pattern)
  Dir.glob(File.join(File.dirname(__FILE__), pattern)).each {|f| require f }
end
def load_local_lib(pattern)
  Dir.glob(File.join(File.dirname(__FILE__), pattern)).each {|f| load f }
end

require "config/environment.rb"


class StimbleTunes < Sinatra::Base
  helpers Sinatra::HTMLEscapeHelper
  helpers Sinatra::StimbleExtensions
  
  
  get '/' do
    puts 'fsdfsf'
    @folders = Dir.glob(current_library+'/*').collect{|d| File.basename d}
    session[:current_directory]  = '/'
    haml :folders
  end

  get '/login' do
    haml :login
  end
  post '/login' do
    set_cookie(Settings[:admin_cookie_key], Settings[:admin_cookie_value]) if params[:password] == Settings[:admin_password]
    redirect '/'
  end
  get '/logout' do
    request.cookies[Settings.admin_cookie_key] = nil
    redirect '/login'
  end

  get '/folders/*' do
    folder_path = File.join(params['splat'])
    full_path = File.join(current_library, folder_path)
    raise InvalidFile, "Tried to display an invalid folder: #{folder_path}" if !File.exists?(full_path)
    session[:current_directory] = File.join(params['splat'])
    @folders = Dir.glob(File.join(full_path, '/*')).collect{|d|  File.basename(d) if File.directory?(d)}
    @folders.delete_if{|f| f.nil?}
    @songs = Song.find(:all, :conditions=>["path like ?", File.join(current_library, session[:current_directory]) ], :limit=>100)
    haml :folders
  end

  get '/identify/*' do
    session[:current_directory] = File.join(params['splat'])
    path = File.join(current_library, File.join(params['splat']))
    raise SecurityException, "Invalid Path: #{path[0...current_library.length]}\n #{Settings[:music_folders].inspect}" if Settings[:music_folders].grep(/#{path[0...current_library.length]}/).blank?
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
    PlaylistSong.delete(params[:playlist_song_id])
    @playlist = session[:current_playlist] || Playlist.first
    # @playlist.playlist_songs.delete(PlaylistSong.find(params[:playlist_song_id]))
    if request.xhr?
      @playlist.songs.size
      puts "it was xhr"
    else
      puts "song removed, not thru ajax"
      # redirect '/playlist'  #use a 303 code to force reset method to GET
    end
  end

  put "/playlist/reorder/" do
    # TODO
    pp params
    playlist = Playlist.find(session[:playlist_id])
    playlist_song = playlist_song.playlist_songs.find(params[:middle])
    # playlist.insert_song_at_position(song, params[:position])
    puts "reordering playlist " #todo
    playlist
  end

  get '/playlist' do
    @playlist = Playlist.first || Playlist.create
    session[:playlist_id] = @playlist.id
    haml :playlist # :layout => :playlist_layout
  end

  get '/libraries/*' do
    new_media_library = File.join('/', params[:splat])
    if params['splat'].first != ''
      puts "changing current_library from #{current_library}"
      # current_library = File.join('/', params[:splat])  #TODO why does this fail?
      if Settings[:music_folders].include?(new_media_library)
        session[:current_library] = File.join('/', params[:splat])
      else
        raise SecurityException, "tried to change current_library to directory outside of settings: #{File.join('/', params[:splat])}"
      end
    end
    @libraries = Settings[:music_folders]
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
  
end