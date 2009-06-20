class StimbleTunes < Sinatra::Base

  configure do
    load_local_lib(File.dirname(__FILE__)+"/../app/models/**/*.rb")
    require_local_lib(File.dirname(__FILE__)+"/../lib/**/*.rb")
  
    load File.join(File.dirname(__FILE__), 'settings.rb')
    set :app_file, File.expand_path(File.dirname(__FILE__) + '/../app.rb')
    set :public,   File.expand_path(File.dirname(__FILE__) + '/../public')
    set :views,    File.expand_path(File.dirname(__FILE__) + '/../views')

    ActiveRecord::Base.establish_connection( 
      :adapter => "sqlite3",
      :database => File.join(File.dirname(__FILE__),"/../db/development.sqlite3" )
    )
    ActiveRecord::Base.logger = Logger.new(STDOUT)

    # Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://jukebox.db')  

    set :sessions => true
    set :root => File.dirname(__FILE__)+'../'
    set :app_file  => File.join(File.dirname(__FILE__), '/../app.rb')
    # set :views  => File.join(File.dirname(__FILE__), 'app/views')
  end

  configure(:test) do
    Settings[:music_folders] = [File.join(File.dirname(__FILE__), '..','test','fixtures')]
    ActiveRecord::Base.establish_connection( 
      :adapter => "sqlite3",
      :database => File.join( File.dirname(__FILE__),"../db/jukebox_test.sqlite3" ) 
    )
    ActiveRecord::Base.logger = Logger.new(File.join( File.dirname(__FILE__),'..', "log", "test.log" ) )
    File.join(File.dirname(__FILE__), '..','fixtures', 'Music')
    set :logging => true
  end
  
end