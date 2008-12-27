require 'earworm'
require 'id3lib'
require 'flacinfo'

class Song < ActiveRecord::Base
  has_many :playlist_songs
  has_many :playlists, :through => :playlist_songs
  
  validates_uniqueness_of :filename, :scope => :path
  # validates_length_of :path, :within => 2..255
  
  # def validate
  #     errors.add("File", "is not a regular file: #{full_path}") if !File.file?(full_path)
  # end

  def Song.earworm
    @ew = Earworm::Client.new(Settings.music_dns_api_key)
  end
  
  def Song.find_or_create_from_file(file_path)
    return nil if !File.file?(file_path)
    song = Song.find(:first, :conditions => {:filename=>File.basename(file_path), 
                                             :path => file_path.gsub("/#{File.basename(file_path)}",'')})
    if song.blank? or song.needs_info?
      song = Song.new({:filename=>File.basename(file_path), 
                       :path => file_path.gsub("/#{File.basename(file_path)}",''),
                       :format =>File.extname(file_path).downcase.gsub(/^\./, '') } )
     case song.format
     when 'mp3'
       song.update_attributes(song.parse_id3) 
     when 'flac'
       song.update_attributes(song.parse_flac)
     when 'ogg'
     when 'wav'
     # when 'aif'
     # when 'mp4'
     # when 'wma'
     # when 'aac'
     else
       puts "\n Do not know how to deal with format #{song.format}\n"
     end
     # song.update_attributes(song.parse_aac) if song.format.scan /aac/
    end
  end

  def earworm
    begin
      ear = Song.earworm.identify( :file => self.full_path )
      pp ear
      { :artist   => ear.artist_name, 
        :title    => ear.title, 
        :metadata => ear.to_yaml,
        :muisc_dnsed_at => Time.now
      }
    rescue  
      {}
    end
  end
  
  def parse_id3
        # require 'id3lib'
        tag = ID3Lib::Tag.new(full_path)
        {
          :artist  => tag.artist,
          :title  => tag.title,
          :album  => tag.album,
          :track  => tag.track, #[/^(\d+)/]
          :genre  => tag.genre,
          :year  => tag.year
        }
  end
  def id3
    ID3Lib::Tag.new(full_path)
  end
  
  def parse_flac
    # require 'flacinfo'
    flac = FlacInfo.new(full_path)
    year = flac.tags['date'] || flac.tag['year']
    {
      :artist => flac.tags['artist'],
      :title  => flac.tags['title'],
      :album  => flac.tags['album'],
      :track  => flac.tags['tracknumber'], #[/^(\d+)/]
      :genre  => flac.tags['genre'],
      :year   => year
    }
  end
  
  def relative_path(library_path)
    File.join(path.gsub(library_path, ''), filename)
  end
  
  def needs_info?
    !(artist && title && album && year && length && format)
  end
    
  def full_path
    return path if filename.nil?
    File.join(path, filename)
  end
  
  def playable?
    File.file?()
    #TODO: is this file playable?
    #TODO: extend to play by open.uri(url)
  end
  
  def to_s
    title || filename
  end
  
end