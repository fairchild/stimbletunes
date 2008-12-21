class Song < ActiveRecord::Base
  def info
    metadata
  end
  
  def Song.find_or_create_from_file
    
  end
end