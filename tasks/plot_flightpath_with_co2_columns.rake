require 'benchmark'

desc "Plot columns of CO2"
task :plot_flightpath_with_co2_columns do
  output_path = ENV["OUTPUT_PATH"] || "#{GTRON_ROOT}/output"
  get_db_conn(GTRON_ENV)

  kml = KMLFile.new
  doc = KML::Document.new(:name => "CO2 Columns")
  

  dps = DataPoint.find(:all)
  
  heading = 0
  column_coords = []
  #assemble datapoint tuples as [Column Pair coordinates, CO2 measure]
  dps.each_with_index do |dp, i|
    if dp.co2_ppm
      if i < (dps.size-1)
        heading = KmlTools.heading([dp.lon, dp.lat], 
                                   [dps[i+1].lon, dps[i+1].lat])
      end
      column_coords << [KmlTools.column_pair(dp.lon, dp.lat, dp.altitude,
                                              heading, 150), dp.co2_ppm]
    end
  end
	
  # PPM Tolerance: 5%
  ppm_tolerance = 0.05

  #create polygons from computed coordinates.
  to_skip = [] # Because I don't feel like thinking of a better way to do this
  column_coords.each_with_index do |c, i|
    if i < column_coords.size-1 and !to_skip.include?(i)
      sty = KML::Style.new(:poly_style => KML::PolyStyle.new(
        :color => Co2ColorCode.colorify(c[1]), :outline => false))
      to_skip << i+1 
	  tolerance = { :up => c[1] * (1+ppm_tolerance), :down => c[1] * (1-ppm_tolerance) }
	  # Fuck line character limits
	  if(tolerance[:up] > column_coords[i+1][1] and tolerance[:down] < column_coords[i+1][1] and i < column_coords.size-2)
		coords = c[0].reverse + column_coords[i+2][0] + [c[0][1]]
	  else
	  # Because Andy is an idiot:
	  #puts "First: "+c[0].reverse.join(", ") + "Second: " + column_coords[i+1][0].join(", ") + "Third: " + [c[0][1]].join(", ")
		coords = c[0].reverse + column_coords[i+1][0] + [c[0][1]]
	  end

      col = KML::Polygon.new( :outer_boundary_is => 
                             KML::LinearRing.new(:coordinates => coords),
                            :altitude_mode => 'absolute',
                            :extrude => true)
      placemark = KML::Placemark.new( :name => c[1] )
      placemark.features << sty << col
      doc.features << placemark
    end
  end
  kml.objects << doc
  File.open("#{output_path}/co2_columns.kml", "w") {|f| f.write kml.render}
end
