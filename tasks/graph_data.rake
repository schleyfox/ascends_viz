desc "Exploratory task to graph data for verification"
task :graph_data do
  output_path = ENV["OUTPUT_PATH"] || "#{GTRON_ROOT}/output"
  get_db_conn(GTRON_ENV)

  files = Dir.glob("input/102007_flight3/itt/*.dbl")

  gps_file = "input/102007_flight3/itt/2007_10_20_10_46_in-situ_gps_serial_data.txt"

  out_file = File.open("#{output_path}/foo.dat", "w")
  
  data_points = []
  out_file.puts("TimeStamp\tRef_On\tRef_Side\tRef_Off\tSci_On\tSci_Side\tSci_Off\tLat\tLon")

  files.each do |file|
    n = (File.size(file)/(9.0*8.0)).floor

    for i in (0...n)
      offset = 9*8*i #bytes
      dat = IO.read(file, 9*8, offset).unpack(DataFormats::CO2)
      data_points << [dat[0].floor.to_i] + dat[1,3] + dat[5,3] 
    end
  end

  # generalize this into average_to_second method
  avg_data_points = data_points.inject({}) do |acc, i|
    acc[i[0]] ||= []
    acc[i[0]] << i
    acc
  end.values.map do |dps|
    dps.inject([]) do |acc, dp|
      acc[0] = dp[0]
      cdr(dp).each_with_index do |x, i|
        acc[i+1] ||= 0
        acc[i+1] += x
      end
      [Time.at(acc[0])] + cdr(acc).map{|x| x/dps.size}
    end
  end.sort {|a,b| a[0] <=> b[0]}

  data_points_hash = avg_data_points.inject({}) do |h, i|
    h[car(i) - 66.years] = i
    h
  end

  gps = File.read(gps_file).split("\r\n").map do |line|
    d = line.split(",")
    t = Date.strptime(d[0] + " " + d[1], "%m/%d/%Y %H:%M:%S")
    time = Time.mktime(t.year, t.month, t.day, t.hour, t.min, t.sec)

    lat = make_lat_lon(d[8], d[9])
    lon = make_lat_lon(d[10], d[11])
  end

    

  out_file.write avg_data_points.map{|m| m.join("\t")}.join("\n")

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
