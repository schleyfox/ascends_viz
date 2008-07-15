EPOCH_FAIL = 2082844800 #seconds between 1904 and 1970

class DataPoint < ActiveRecord::Base
  belongs_to :flight

  def self.from_files(dir_name, flight)
    dps = ary_to_time_hash(
      from_itt_data(dir_name)).merge(
        ary_to_time_hash(from_insitu_data(dir_name, flight.date))) do |k, itt, insitu|
          [k] + cdr(itt) + cdr(insitu)
        end.values.select{|x| x.size >= 10}

    dps.each do |dp|
      DataPoint.create( :time => dp[0].to_i,
                        :itt_co2 => dp[5]/dp[2], #ratio of backscatter to reference
                        :lat => dp[7],
                        :lon => dp[8],
                        :altitude => dp[9],
                        :insitu_co2 => dp[10],
                        :flight =>  flight)
    end
  end

  private

  # Array Format: [TimeStamp, CO2_PPM]
  def self.from_insitu_data(dir_name, date)
    co2 = cdr(File.read(Dir.glob("#{dir_name}/insitu/lear*.txt").first).split(/\r?\n/))
    co2.map! do |x| 
      l = x.split(/,\s+/)
      [date.strftime("%s").to_i + l[1].to_i + 4.hours, l[2].to_f]
    end
    puts car(car(co2))
    co2
  end

  def self.from_itt_data(dir_name)
    files = Dir.glob("#{dir_name}/itt/*.dbl")
  
    gps_file = Dir.glob("#{dir_name}/itt/*in-situ_gps_serial_data.txt").first
  
    # Array Format: [TimeStamp,Ref_On,Ref_Side,Ref_Off,Sci_On,Sci_Side,Sci_Off,Lat,Lon,Alt]
  
    data_points = []
    data_points_hash = {}
    file_thread = Thread.new do
      files.each do |file|
        n = (File.size(file)/(9.0*8.0)).floor
    
        for i in (0...n)
          offset = 9*8*i #bytes
          dat = IO.read(file, 9*8, offset).unpack(DataFormats::CO2)

          #adjust for epoch difference
          data_points << [dat[0].floor.to_i - EPOCH_FAIL] + dat[1,3] + dat[5,3] 
        end
      end
    
      avg_data_points = average_to_second(data_points)

      data_points_hash = ary_to_time_hash(avg_data_points)
    end
    gps_hash = {}
    gps_thread = Thread.new do

      required_attributes = [0,1,8,9,10,11,16]
      gps = cdr(File.read(gps_file).split("\r\n")).map do |line|
        d = line.split(",")
        if required_attributes.all? {|i| !d[i].blank? && !d[i].include?('_') }
          timestamp = "#{d[0]} #{d[1]}"
          t = DateTime.strptime(timestamp, "%m/%d/%Y %H:%M:%S") 
          time = Time.gm(t.year, t.month, t.day, t.hour, t.min, t.sec).to_i
          time += 4.hours.to_i
    
          lat = make_lat_lon(d[8], d[9])
          lon = make_lat_lon(d[10], cdr(d[11]))
          alt = d[15].to_i
          [time, lat, lon, alt]
        else
          nil
        end
      end.compact
    
      avg_gps = average_to_second(gps)

      gps_hash = ary_to_time_hash(avg_gps)
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
    angle = (theta[0,2].to_i + (theta[2,2].to_i + theta[4...theta.size].to_i/1000.0)/60.0).to_f
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
        [acc[0]] + cdr(acc).map{|x| x/points.size}
      end
    end.sort {|a,b| a[0] <=> b[0]}
  end

  def self.ary_to_time_hash(ary)
    ary.inject({}) do |h, i|
      h[car(i)] = i
      h
    end
  end
end
