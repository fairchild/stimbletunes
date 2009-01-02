class Playlist < ActiveRecord::Base
  has_many :songs, :through => :playlist_songs
  has_many :playlist_songs
  
  def <<(song)
    pos = playlist_songs.maximum(:position).to_i + 1
    playlist_songs.create(:position=>pos, :playlist=>id, :song=>song)
  end
  
  def insert_at_position(place)
    #TODO
  end
  
end