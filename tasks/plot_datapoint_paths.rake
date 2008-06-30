desc "Plots the flightpath in Google Earth"
task :plot_datapoint_paths do
  output_path = ENV["OUTPUT_PATH"] || "#{GTRON_ROOT}/output"
  get_db_conn(GTRON_ENV)
  kml = KMLFile.new
  doc = KML::Document.new(:name => "ASCENDS Flight Paths")
  line = KML::LineString.new
  style = KML::Style.new(:id => 'default_line')
  style.line_style = KML::LineStyle.new(:color => 'ff0300dc', :width => '2')
  placemark = KML::Placemark.new(:name => 'Flight Path',
                                 :style_url => '#default_line')
  line.altitude_mode = 'absolute'
  line.coordinates = DataPoint.find(:all).map do |dp|
    [dp.lon, dp.lat, dp.altitude + 25]
  end
  placemark.features << line
  doc.features << style << placemark

  kml.objects << doc
  File.open("#{output_path}/datapoint_paths.kml","w") {|f| f.write kml.render }
end
