class DataPoint < ActiveRecord::Base
  belongs_to :flight

  def self.from_files(dir_name)
    gps = File.read(Dir.glob("#{dir_name}/nav*.txt").first).split("\r\n")
    gps = gps[8...gps.size]
    data_points = gps.map do |line|
      dp = DataPoint.new
      data = line.split("\t").values_at(0,10,11,12)
      dp.time = data.shift
      dp.lon = data.shift
      dp.lat = data.shift
      dp.altitude = data.shift
      dp.save
      dp
    end
  end

end
