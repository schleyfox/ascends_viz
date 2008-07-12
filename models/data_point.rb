class DataPoint < ActiveRecord::Base
  belongs_to :flight

  def self.from_files(dir_name, flight)
    from_itt_data(dir_name).each do |dp|
      DataPoint.create( :time => dp[0].to_i,
                        :itt_co2 => dp[5],
                        :lat => dp[7],
                        :lon => dp[8],
                        :altitude => dp[9],
                        :flight =>  flight)
    end
  end

  private

  #currently failtronic, do not use
  def self.from_insitu_data(dir_name)
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
        dp.insitu_co2 = co2.shift
      end
      dp
    end
    #data_points.each{|dp| dp.save }
    ActiveRecord::Base.logger.warn( 
      "DROPPING #{co2.size} PIECES OF VERY IMPORTANT DATA") if co2.size
    data_points
  end

  def self.from_itt_data(dir_name, timezone_offset=-5)
    files = Dir.glob("#{dir_name}/itt/*.dbl")
  
    gps_file = Dir.glob("#{dir_name}/itt/*in-situ_gps_serial_data.txt").first
  
    # Array Format: [TimeStamp,Ref_On,Ref_Side,Ref_Off,Sci_On,Sci_Side,Sci_Off,Lat,Lon,Alt]
  
    data_points = []
    data_points_hash = {}
    file_thread = Thread.new do
    #timezone_offset += 1
      files.each do |file|
        n = (File.size(file)/(9.0*8.0)).floor
    
        for i in (0...n)
          offset = 9*8*i #bytes
          dat = IO.read(file, 9*8, offset).unpack(DataFormats::CO2)
          #for some reason the dates are correct, only in the wrong year, 2073
          #Don't have any idea why adding one to the offset works, but it does
          #Also my fucking system clock is set in UTC so Ruby can't see my true offset (easily at least) so it's hardcoded
          puts Time.at(dat[0].floor.to_i - (Time.utc(1970)-Time.utc(1904))+timezone_offset.hours+((Time.now).gmt_offset*-1))
          data_points << [Time.at(dat[0].floor.to_i - (Time.utc(1970)-Time.utc(1904))+timezone_offset.hours+((Time.now).gmt_offset*-1))] + dat[1,3] + dat[5,3] 
        end
      end
    
      avg_data_points = average_to_second(data_points)
    
      data_points_hash = avg_data_points.inject({}) do |h, i|
        h[car(i)] = i
        h
      end

    end
    gps_hash = {}
    gps_thread = Thread.new do

      required_attributes = [0,1,8,9,10,11,16]
      gps = cdr(File.read(gps_file).split("\r\n")).map do |line|
        d = line.split(",")
        if required_attributes.all? {|i| !d[i].blank? && !d[i].include?('_') }
          timestamp = "#{d[0]} #{d[1]}"
          t = DateTime.strptime(timestamp, "%m/%d/%Y %H:%M:%S") 
          time = Time.mktime(t.year, t.month, t.day, t.hour, t.min, t.sec)
    
          lat = make_lat_lon(d[8], d[9])
          lon = make_lat_lon(d[10], cdr(d[11]))
          alt = d[15].to_i
          [time, lat, lon, alt]
        else
          nil
        end
      end.compact
    
      avg_gps = average_to_second(gps)
    
      gps_hash = avg_gps.inject({}) do |h, i|
        h[car(i)] = i
        h
      end

    end
  
    file_thread.join
    gps_thread.join
  
    combined_data = data_points_hash.merge(gps_hash) do |k, dp, coord|
      [k] + cdr(dp) + [coord[1], coord[2], coord[3]]
    end.values.select do |elem|
      elem.size == 10
    end
  end

  def self.make_lat_lon(hemi, theta)
    angle = (theta[0,2] + '.' + theta[2...theta.size]).to_f
    if ["S", "W"].include? hemi
      angle *= -1.0
    end
    angle
  end
  
  def self.average_to_second(ary)
    ary.inject({}) do |acc, i|
      acc[i[0]] ||= []
      acc[i[0]] << i
      acc
    end.values.map do |points|
      points.inject([]) do |acc, point|
        acc[0] = point[0]
        cdr(point).each_with_index do |x, i|
          acc[i+1] ||= 0
          acc[i+1] += x
        end
        [Time.at(acc[0])] + cdr(acc).map{|x| x/points.size}
      end
    end.sort {|a,b| a[0] <=> b[0]}
  end
end
