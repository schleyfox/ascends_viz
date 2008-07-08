desc "Exploratory task to graph data for verification"
task :graph_data do
  output_path = ENV["OUTPUT_PATH"] || "#{GTRON_ROOT}/output"
  get_db_conn(GTRON_ENV)

  files = Dir.glob("input/102007_flight3/itt/*.dbl")

  gps_file = "input/102007_flight3/itt/2007_10_20_10_46_in-situ_gps_serial_data.txt"

  out_file = File.open("#{output_path}/foo.dat", "w")
  
  data_points = []
  out_file.puts("TimeStamp\tRef_On\tRef_Side\tRef_Off\tSci_On\tSci_Side\tSci_Off\tLat\tLon")

  data_points_hash = {}
  file_thread = Thread.new do
    files.each do |file|
      n = (File.size(file)/(9.0*8.0)).floor
  
      for i in (0...n)
        offset = 9*8*i #bytes
        dat = IO.read(file, 9*8, offset).unpack(DataFormats::CO2)
        data_points << [dat[0].floor.to_i - 66.years - 12.hours] + dat[1,3] + dat[5,3] 
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
    required_attributes = [0,1,8,9,10,11]
    gps = cdr(File.read(gps_file).split("\r\n")).map do |line|
      d = line.split(",")
      if required_attributes.all? {|i| !d[i].blank? && !d[i].include?('_') }
        timestamp = "#{d[0]} #{d[1]}"
        t = DateTime.strptime(timestamp, "%m/%d/%Y %H:%M:%S") 
        time = Time.mktime(t.year, t.month, t.day, t.hour, t.min, t.sec)
  
        lat = make_lat_lon(d[8], d[9])
        lon = make_lat_lon(d[10], d[11])
        [time, lat, lon]
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
    dp + [coord[1], coord[2]]
  end.values.select do |elem|
    elem.size == 9
  end

  out_file.write combined_data.map{|m| m.join("\t")}.join("\n")

  out_file.close
end

def make_lat_lon(hemi, theta)
  angle = (theta[0,2] + '.' + theta[2...theta.size]).to_f
  if ["S", "W"].include? hemi
    angle *= -1.0
  end
  angle
end

def average_to_second(ary)
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
