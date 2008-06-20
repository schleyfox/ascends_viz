require File.dirname(__FILE__) + '/../test_helper.rb'

class TestDataPoint < Test::Unit::TestCase
  def setup
    get_db_conn(GTRON_ENV)
    Flight.delete_all
    DataPoint.delete_all
    Gigantron.migrate_dbs
  end

  should_belong_to :flight

  context "Loaded sample data" do
    setup do
      Flight.load(Dir.glob("#{GTRON_ROOT}/test/sample_data/*"))
    end

    should "create 10 data points" do
      assert_equal 10, DataPoint.find(:all).size
    end
  end

end
