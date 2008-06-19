class Flight < ActiveRecord::Base
  has_many :data_points

  def self.load(dir_names)
    flights = []
    dir_names.each do |dir|
      _t, date, flight_number = dir.match(/(\d{6})_flight(\d+)/).to_a
      
      flight = Flight.new(:date => Date.strptime(date, "%m%d%y"),
                          :flight_number => flight_number)
      flight.save
      flight.data_points = DataPoint.from_files(dir)
      flight.save
      flights << flight
    end
    flights
  end

end
