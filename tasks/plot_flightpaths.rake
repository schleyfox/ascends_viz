desc "Plots the flightpath in Google Earth"
task :plot_flightpaths do
  output_path = ENV["OUTPUT_PATH"] || "#{GTRON_ROOT}/output"
  get_db_conn(GTRON_ENV)
  kml = KMLFile.new
  doc = KML::Document.new(:name => "ASCENDS Flight Paths")

  style = KML::Style.new(:id => 'default_line')
  style.line_style = KML::LineStyle.new(:color => 'ff0300dc', :width => '2')
  doc.features << style

  doc.features += Flight.find(:all).map do |flight|
    line = KML::LineString.new
    placemark = KML::Placemark.new(
          :name => "Flight #{flight.flight_number} Path",
          :style_url => '#default_line')
    line.altitude_mode = 'absolute'
    line.coordinates = flight.data_points.map do |dp|
      [dp.lon, dp.lat, dp.altitude]
    end
    placemark.features << line
    placemark
  end

  kml.objects << doc
  File.open("#{output_path}/datapoint_paths.kml","w") {|f| f.write kml.render }
end
