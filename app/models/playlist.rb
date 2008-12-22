class Playlist < ActiveRecord::Base
  has_many :songs, :through => :playlist_songs
  has_many :playlist_songs
end