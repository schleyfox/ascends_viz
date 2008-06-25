desc "Plot columns"
task :plot_flightpath_with_co2_columns do
  get_db_conn(GTRON_ENV)
  kml = KMLFile.new
  doc = KML::Document.new(:name => "CO2 Columns")
  doc.features
  dps = DataPoint.find(:all)
  heading = 0
  dps.each_with_index do |dp, i|
    if dp.co2_ppm
      placemark = KML::Placemark.new( :name => dp.co2_ppm)
      sty = KML::Style.new(:poly_style => KML::PolyStyle.new(:color => Co2ColorCode.colorify(dp.co2_ppm), :outline => false))
      
      if i < (dps.size-1)
        heading = KmlTools.heading([dp.lon, dp.lat], 
                                   [dps[i+1].lon, dps[i+1].lat])
      end
      
      col = KmlTools.square_column(dp.lon, dp.lat, dp.altitude, heading, 150)
      placemark.features << sty << col
      doc.features << placemark
    end
  end.compact
  kml.objects << doc
  File.open("output/co2_columns.kml", "w") {|f| f.write kml.render}
end
