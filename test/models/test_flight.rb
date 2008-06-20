require File.dirname(__FILE__) + '/../test_helper.rb'

class TestFlight < Test::Unit::TestCase
  def setup
    get_db_conn(GTRON_ENV)
    Gigantron.migrate_dbs
    Flight.delete_all
    DataPoint.delete_all
    @data_dir = "#{GTRON_ROOT}/test/sample_data"
  end

  should_have_many :data_points

  context "Using sample directory structure" do
    setup do
      flights = Flight.load(Dir.glob("#{@data_dir}/*"))
      @flight = flights.first
      assert @flight
    end

    should "get flight number" do
      assert_equal 1, @flight.flight_number
    end

    should "get date" do
      assert_equal Date.new(2008,6,19), @flight.date
    end
  end

end
