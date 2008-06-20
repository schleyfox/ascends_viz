class DataPoint < ActiveRecord::Base
  belongs_to :flight

  def self.from_files(dir_name)
    gps = File.read(Dir.glob("#{dir_name}/nav*.txt").first).split("\r\n")
    gps = gps[8...gps.size]
    data_point_coords = gps.map do |line|
      dp = DataPoint.new
      data = line.split("\t").values_at(0,10,11,12)
      dp.time = data.shift
      dp.lon = data.shift
      dp.lat = data.shift
      dp.altitude = data.shift
      dp.save
      dp
    end

    co2 = File.read(Dir.glob("#{dir_name}/lear*.txt").first).split("\r\n")
    co2 = co2[1...co2.size].map{|x| x.split(/,\s+/)[2].to_f }
    data_points = data_point_coords.map do |dp|
      if dp.altitude > 0
        dp.co2_ppm = co2.shift
        dp.save
      end
      dp
    end
    puts "DROPPING #{co2.size} PIECES OF VERY IMPORTANT DATA"
    data_points
  end

end
