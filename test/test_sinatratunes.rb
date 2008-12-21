require 'test_helper'
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
      
      should " be able to stream a file" do
        get_it '/play/Untitled/another_folder/touched'
        assert_equal 200, @response.status
        assert_equal "binary", @response.headers["Content-Transfer-Encoding"]
      end
      
      should "be able to browse a folder" do
        get_it '/folders/Untitled/'
        assert_equal 200, @response.status
        assert @response.body.scan('another_folder')
      end
      
      should "be able to create a song" do
        song = Song.create({:title => 'test song'})
        assert song.valid?
      end
    end
    
    context "Song should " do
      setup do
        @song = Song.create({:title => 'Next song'})
        assert @song.valid?
      end
    end
        
    should "be able to find from a filename" do
     #pending Song.find_or_create_from_file
    end
  end
  
  

end