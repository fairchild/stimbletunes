require 'sinatra/base'

module Sinatra
  module HTMLEscapeHelper
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end
  
  module StimbleExtensions
    def admin?
      request.cookies[Settings[:admin_cookie_key]] == Settings[:admin_cookie_value]
    end
    def auth
      stop [ 401, 'Not authorized' ] unless admin?
    end
    def current_library
      session[:current_library] ? session[:current_library] : session[:current_library] = Settings[:music_folders].last
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
  
    # Recursivley scan folder for media files, parsing meta data and inserting in database along the way
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
end
