require File.join(File.dirname(__FILE__), 'test_helper.rb')
class SinatratuneTest < Test::Unit::TestCase

  context "Sinatratune" do
    
    context "getting the index" do
      setup do
        get_it '/'
        assert_equal 200, @response.status
      end
      
      should "respond" do
        assert @response.body
      end
    end
    
    context "/play " do
      should "be able to stream a file" do
        get_it '/play/Mogwai/Untitled/another_folder/touched'
        assert_equal 200, @response.status
        assert_equal "binary", @response.headers["Content-Transfer-Encoding"]
      end
      
      should " not be able to stream a file outside of the library" do
        get_it '/play/../../'
        assert_equal 401, @response.status
      end
    end
    
    context "browse folders/ " do
      
      should "be able to browse a folder" do
        get_it '/folders/Untitled/'
        assert_equal 200, @response.status
        assert @response.body.scan('another_folder')
      end
      
      should "not be able to browse a folder outside of the library" do
        get_it '/folders/../../'
        assert_equal 401, @response.status
      end
    end
    
    context "should be able to identify music files" do
      should "be able to identify a song" do
        get_it "/identify/Mogwai"
        assert_equal 200, @response.status
      end
    end
    
    context "Song should " do
      setup do
        @song = Song.create({:title => 'Next song'})
        assert @song.valid?
      end
      
      should "be able to create a song" do
         song = Song.create({:title => 'test song'})
         assert song.valid?
       end
    end
        
    should "be able to find from a filename" do
     #pending Song.find_or_create_from_file
    end
  end
  
  

end