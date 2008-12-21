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
      
      should "be able to create a song" do
        song = Song.create({:title => 'test song'})
        assert song.valid?
      end
    end
  end

end