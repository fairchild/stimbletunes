require File.join(File.dirname(__FILE__), 'test_helper.rb')
class SinatratuneTest < Test::Unit::TestCase
  include Rack::Utils

  context "Sinatratune" do
    setup do
      @test_file = "/Users/fairchild/Sites/sinatratunes/test/fixtures/Music/Mogwai/Rock Action/06. Robot Chant.mp3"
    end
    
    should  " Have valid test file" do
      puts test_mp3_full_file_path+"||"
      assert_equal test_mp3_full_file_path, File.join(current_library, test_mp3_relative_file_path)
      assert @test_file.scan(test_mp3_full_file_path)
      assert File.exists?(test_mp3_full_file_path)
    end
    should "have defined exceptions" do
      assert_nothing_raised do
        InvalidFile
        AppError
      end
    end
    
    context "getting the index" do
      setup do
        get_it '/'
        assert_equal 200, @response.status
      end
      
      should "respond" do
        assert @response.body
        assert_not_nil current_library
      end
    end
    
    context "/play/#{escape test_mp3_relative_file_path} " do
      setup do
         @song = Song.create({:title => 'The Song', :path => File.join(current_library, '/Mogwai/Rock Action'), :filename => '06. Robot Chant.mp3'})
      end
      # should "be able to stream a file" do
      #      puts @song.full_path
      #      assert_not_nil @song
      #      get_it escape("/play/#{@song.full_path}")
      #      assert File.exists?(@song.full_path) 
      #      assert_equal 200, @response.status
      #      assert_equal "binary", @response.headers["Content-Transfer-Encoding"]
      #    end
      #    
      should " not be able to stream a file outside of the library" do
        assert_raise InvalidFile do  get_it '/play/../../' end
        # assert_equal 401, @response.status 
        # assert_exception_raised "ERROR: Cannot find that file"
      end
    end
    
    context "/folders/ " do
      
      should "be able to browse a folder" do
        get_it "/folders/#{escape(test_mp3_relative_file_path)}"
        assert_equal 200, @response.status
        assert @response.body.scan('another_folder')
      end
      
      #TODO
      # should "raise an exception if trying to browse a folder outside of the library" do
      # #   assert_raise SecurityException do get_it("/folders/../../../../../../../../")  end
      # #   assert_raise SecurityException do get_it("/folders/../file_outside_of_library.txt") end        
      #   get_it "/folders/bogus"
      #   assert_equal 404, @response.status
      # end
    end
    
    # context "should be able to identify music files" do
    #   should "be able to identify a song" do
    #     get_it "/identify/Mogwai"
    #     assert_equal 200, @response.status
    #   end
    # end
    
    context "Song should " do
      setup do
        Song.delete_all
        @song = Song.create({:title => 'The Song', :path => File.join(current_library, '/Mogwai/Rock Action'), :filename => '06. Robot Chant.mp3'})
      end
      
      should "be able to create a song" do
        assert @song.valid?
       end
    end
        
    should "be able to find from a filename" do
     #pending Song.find_or_create_from_file
    end
  end
  
  context "/playlist/ should display and play a playlist" do
    setup do
      @playlist = Playlist.create
      @song = Song.create({:title => 'The Song', :path => File.join(current_library, '/Mogwai/Rock Action'), :filename => '06. Robot Chant.mp3'})
      @songs = Song.all
      assert @songs.size>0
      @playlist.songs << @songs
    end
    should "have songs on the playlist" do
      assert @playlist.songs.length>0
      get_it "/playlist/#{@playlist.id}"
    end
    should "enque a song to default playlist" do
      get_it "/playlist/enque/#{@song.id}"
      assert_equal 200, @response.status
    end
  end
  
  

end