desc "Plot columns of CO2"
task :plot_flightpath_with_co2_columns do
  output_path = ENV["OUTPUT_PATH"] || "#{GTRON_ROOT}/output"
  get_db_conn(GTRON_ENV)

  kml = KMLFile.new
  doc = KML::Document.new(:name => "CO2 Columns")
  

  dps = DataPoint.find(:all)
  
  heading = 0
  distance = 0
  column_coords = []
  #assemble datapoint tuples as [Column Pair coordinates, CO2 measure]
  dps.each_with_index do |dp, i|
    if dp.itt_co2 
      if i < (dps.size-1)
        start = [dp.lon, dp.lat]
        finish = [dps[i+1].lon, dps[i+1].lat]

        distance = KmlTools.great_circle_distance(start, finish)
        new_heading = KmlTools.heading(start, finish)
        #angle difference formula
        heading = new_heading unless ((((new_heading+180) - heading) % 360) - 180).abs > 90.0
      end
      column_coords << [KmlTools.column_pair(dp.lon, dp.lat, dp.altitude,
                                              heading, 150), dp.itt_co2, heading]
      if distance > 200
        column_coords << nil
      end
    end
  end
	
  column_coords.each_with_index do |c, i|
    if i < column_coords.size-1 and c and column_coords[i+1] 
      sty = KML::Style.new(:poly_style => KML::PolyStyle.new(
        :color => Co2ColorCode.colorify(c[1]), :outline => false))

      coords = c[0].reverse + column_coords[i+1][0] + [c[0][1]]

      col = KML::Polygon.new( :outer_boundary_is => 
                             KML::LinearRing.new(:coordinates => coords),
                            :altitude_mode => 'absolute',
                            :extrude => true)
      placemark = KML::Placemark.new( :name => c[2] )
      placemark.features << sty << col
      doc.features << placemark << KmlTools.cube(coords, 50, Co2ColorCode.colorify(c[1]), KmlTools.DEFAULT_BOX)
    end
  end
  kml.objects << doc
  #puts kml.objects[0].features
  File.open("#{output_path}/co2_columns.kml", "w") {|f| f.write kml.render}
end
