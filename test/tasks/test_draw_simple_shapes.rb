require File.dirname(__FILE__) + '/../test_helper.rb'

class TestDrawSimpleShapes < Test::Unit::TestCase
  def setup
    ENV["OUTPUT_PATH"] = TEST_TMP
    bare_setup

    get_db_conn(GTRON_ENV)
    @rake = Rake::Application.new
    Rake.application = @rake
    load File.dirname(__FILE__) + '/../../tasks/draw_simple_shapes.rake'
  end

  context "Drawing Shapes" do
    setup { @rake["draw_simple_shapes"].invoke }

    should "make kml file" do
      assert File.exists?("#{TEST_TMP}/simple_shapes.kml")
    end
  end

  def teardown
    Rake.application = nil
    bare_teardown
  end
end
