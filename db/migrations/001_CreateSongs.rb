class CreateSongs < ActiveRecord::Migration
  def self.up
    create_table :songs do |t|
      t.string :path
      t.string :filename
      t.string :title
      t.string :artist
      t.integer :length
      t.string :format
      t.integer :bitrate
      t.text :metadata
      t.string :metadata_type
      t.string :puid
      t.timestamp :muisc_dnsed_at
      t.string :fingerprint
      t.timestamps
    end
  end

  def self.down
    drop_table :songs
  end
end


#TODO
  # t.string :library  
