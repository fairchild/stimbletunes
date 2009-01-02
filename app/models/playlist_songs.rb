class PlaylistSong < ActiveRecord::Base
  belongs_to :song
  belongs_to :playlist
  
  before_save :store_position
  
  def store_position
    # position = playlist.playlist_songs.maximum(:position).to_i +1 if position.nil?  
  end
end
