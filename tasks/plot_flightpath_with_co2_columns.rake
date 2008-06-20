desc "Plot columns"
task :plot_flightpath_with_co2_columns do
  get_db_conn(GTRON_ENV)
  kml = KMLFile.new
  doc = KML::Document.new(:name => "CO2 Columns")
  doc.features = DataPoint.find(:all).map do |dp|
    KML::Placemark.new( :name => dp.co2_ppm,
      :geometry => KML::Point.new(:coordinates => [dp.lon,dp.lat,dp.altitude+25],
      :altitude_mode => 'absolute'
                                 )
                      ) if dp.co2_ppm
  end.compact
  kml.objects << doc
  File.open("output/co2_columns.kml", "w") {|f| f.write kml.render}
end
