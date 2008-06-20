require File.dirname(__FILE__) + '/../test_helper.rb'

class TestFlight < Test::Unit::TestCase
  def setup
    get_db_conn(GTRON_ENV)
    Gigantron.migrate_dbs
    Flight.delete_all
    DataPoint.delete_all
    
    Flight.create(:flight_number => 7, :date => "2006-09-20")
    @data_dir = "#{GTRON_ROOT}/test/sample_data"

  end

  should_have_many :data_points

  should_not_allow_values_for :date, 102007, 20080619, "02/14/05"
  should_allow_values_for :date, "2009-11-16", "1998-03-04"

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

    should "have 10 data_points" do
      assert_equal 10, @flight.data_points.size
    end
  end

end
