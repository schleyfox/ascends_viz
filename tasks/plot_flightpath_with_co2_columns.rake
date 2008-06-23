desc "Plot columns"
task :plot_flightpath_with_co2_columns do
  get_db_conn(GTRON_ENV)
  kml = KMLFile.new
  doc = KML::Document.new(:name => "CO2 Columns")
  doc.features = DataPoint.find(:all).map do |dp|
    if dp.co2_ppm
      placemark = KML::Placemark.new( :name => dp.co2_ppm)
      sty = KML::Style.new(:poly_style => KML::PolyStyle.new(:color => Co2ColorCode.colorify(dp.co2_ppm), :outline => false))
      cyl = KmlShapes.cylinder(dp.lon, dp.lat, dp.altitude, 100)
      placemark.features << sty << cyl
      placemark
    end
  end.compact
  kml.objects << doc
  File.open("output/co2_columns.kml", "w") {|f| f.write kml.render}
end
