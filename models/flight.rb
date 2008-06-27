class Flight < ActiveRecord::Base
  has_many :data_points

  validates_format_of :date, :with => /\d{4}-\d{2}-\d{2}/, :allow_nil => true

  def self.load(dir_names)
    dir_names.map do |dir|
      _t, date, flight_number = dir.match(/(\d{6})_flight(\d+)/).to_a
      
      flight = Flight.new(:date => Date.strptime(date, "%m%d%y").to_s,
                          :flight_number => flight_number)
      flight.save
      DataPoint.from_files(dir, flight)
      flight
    end
  end

  def date
    Date.strptime(attributes['date'])
  rescue
    attributes['date']
  end

  def date= d
    write_attribute(:date, d.to_s)
  end

end
