require 'test_helper'

class SinatratuneTest < Test::Unit::TestCase

  context "Sinatratune" do
    context "getting the index" do
      setup do
        get_it '/'
      end
      
      should "respond" do
        assert @response.body
      end
    end
  end

end