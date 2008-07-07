class DataPoint < ActiveRecord::Base
  belongs_to :flight

  def self.from_files(dir_name, flight)
    gps = File.read(Dir.glob("#{dir_name}/insitu/nav*.txt").first).split(/\r?\n/)
    gps = gps[8...gps.size]
    data_point_coords = gps.map do |line|
      dp = DataPoint.new
      data = line.split("\t").values_at(0,10,11,12)
      dp.time = data.shift
      dp.lon = data.shift
      dp.lat = data.shift
      dp.altitude = data.shift
      dp.flight_id = flight.id
      dp
    end

    co2 = cdr(File.read(Dir.glob("#{dir_name}/insitu/lear*.txt").first).split(/\r?\n/))
    co2 = co2.map{|x| x.split(/,\s+/)[2].to_f }
    data_points = data_point_coords.map do |dp|
      if dp.altitude > 0
        dp.co2_ppm = co2.shift
      end
      dp
    end
    data_points.each{|dp| dp.save }
    ActiveRecord::Base.logger.warn( 
      "DROPPING #{co2.size} PIECES OF VERY IMPORTANT DATA") if co2.size
    data_points
  end

end
