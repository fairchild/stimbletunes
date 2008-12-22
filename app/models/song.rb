class Song < ActiveRecord::Base
  has_many :playlist_songs
  has_many :playlists, :through => :playlist_songs
  
  def validate
      errors.add("File", "is not a regular file") if !File.file?(full_path)
  end

  def Song.earworm
    @ew = Earworm::Client.new(Settings.music_dns_api_key)
  end
  
  def Song.find_or_create_from_file(file_path)
    return nil if !File.file?(file_path)
    song = Song.find(:first, :conditions => {:filename=>File.basename(file_path), 
                                             :path => file_path.gsub("/#{File.basename(file_path)}",'')})
    if song.blank?
      song = Song.new({:filename=>File.basename(file_path), 
                       :path => file_path.gsub("/#{File.basename(file_path)}",''),
                       :format =>File.extname(file_path).downcase.gsub(/^\./, '') } )
     if song.format == ('mp3')
       song.update_attributes(song.parse_id3) 
     elsif song.format == 'ogg' or song.format=='flac'
       song.update_attributes(song.earworm)
     end
     # song.update_attributes(song.parse_aac) if song.format.scan /aac/
    end
  end

  def earworm
    ear = Song.earworm.identify( :file => self.full_path ) rescue "ERROR: Could not read file: #{full_path}"
    pp ear
    { :artist   => ear.artist_name, 
      :title    => ear.title, 
      :metadata => ear.to_yaml,
      :muisc_dnsed_at => Time.now
    }
  end
  
  def parse_id3
        require 'id3lib'
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
  
  def relative_path(library_path)
    path.gsub(library_path, '')
  end
  
  def needs_info?
    !(artist && title && album && year && length && format)
  end
    
  def full_path
    return path if filename.nil?
    File.join(path, filename)
  end
  
  def to_s
    title || filename
  end
  
end