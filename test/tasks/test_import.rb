require File.dirname(__FILE__) + '/../test_helper.rb'

class TestImport < Test::Unit::TestCase
  def setup
    get_db_conn(GTRON_ENV)
    @rake = Rake::Application.new
    Rake.application = @rake
    ENV["INPUT_PATH"] = "test/sample_data"
    load File.dirname(__FILE__) + '/../../tasks/import.rake'
  end

  context "Import data" do
    setup { @rake["import"].invoke }

    should "create flights" do
      assert_equal 1, Flight.find(:all).size
    end

    should "create datapoints" do
      assert_equal 10, DataPoint.find(:all).size
    end

    should "associate datapoints with flight" do
      assert_equal DataPoint.find(:all).size,
        Flight.find(:first).data_points.size
    end
  end

  def teardown
    Rake.application = nil
  end
end
