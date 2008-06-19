desc "Plots the lats and lons of datapoints as placemarks in Google Earth "
task :plot_datapoint_paths do
  get_db_conn(GTRON_ENV)
  kml = KMLFile.new
  folder = KML::Folder.new(:name => 'ASCENDS Data Points')
  folder.features = DataPoint.find(:all).map do |dp|
    KML::Placemark.new(:name => "Point #{dp.id}",
                       :geometry => KML::Point.new( 
                          :coordinates => [dp.lon, dp.lat, dp.altitude],
                          :altitude_mode => 'absolute'))
  end

  kml.objects << folder
  File.open("output/datapoint_paths.kml","w") {|f| f.write kml.render }
end
