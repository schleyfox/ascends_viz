desc "Plot columns of CO2"
task :plot_co2_columns do
  output_path = ENV["OUTPUT_PATH"] || "#{GTRON_ROOT}/output"
  get_db_conn(GTRON_ENV)

  kml = KMLFile.new
  doc = KML::Document.new(:name => "CO2 Columns")
  
  Flight.find(:all).map do |flight|
    folder = KML::Folder.new(:name => "Flight #{flight.flight_number}")

### @export "Create CO2 Columns"
    column_coords = make_column_coords(flight.data_points.find(:all))

    columns = make_column_placemarks(column_coords)

    folder.features = divide_into_30minute_folders(
      divide_into_minute_folders(columns))
### @end

    doc.features << folder
  end
  kml.objects << doc
  File.open("#{output_path}/co2_columns.kml", "w") {|f| f.write kml.render}
end

def make_column_coords(dps)
  heading = 0
  distance = 0
  column_coords = []
  #assemble datapoint tuples as 
  #[Column Pair coordinates, ITT , Insitu, heading, time]
  dps.each_with_index do |dp, i|
    if dp.itt_co2 
      if i < (dps.size-1)
        start = [dp.lon, dp.lat]
        finish = [dps[i+1].lon, dps[i+1].lat]
  
        distance = KmlTools.great_circle_distance(start, finish)
        new_heading = KmlTools.heading(start, finish)
        #angle difference formula
        heading = new_heading unless 
          ((((new_heading+180) - heading) % 360) - 180).abs > 90.0
      end
      column_coords << [KmlTools.column_pair(dp.lon, dp.lat, dp.altitude,
                                   heading, 150), 
                                   dp.itt_co2, dp.insitu_co2, heading, 
                                   dp.time]
      if distance > 200
        column_coords << nil
      end
    end
  end
  column_coords
end

def make_column_placemarks(column_coords)
  box_tracker, column_tracker = [], []
  max_merges = ENV['max_merges'] || 3
  placemarks = []

  column_coords.each_with_index do |c, i|
    if i < column_coords.size-1 and c and column_coords[i+1] 
      sty = KML::Style.new(:poly_style => KML::PolyStyle.new(
        :color => Co2ColorCode.itt_colorify(c[1]), :outline => false))

      coords = c[0].reverse + column_coords[i+1][0] + [c[0][1]]
      cube_coords = coords
      
      (2..max_merges).each do |m|
        if (within_tolerance?(0.05, c[1], column_coords[i+1][1]) && 
            column_coords[i+m] && !box_tracker.include?(i))

            cube_coords = c[0].reverse + column_coords[i+m][0] + [c[0][1]]
            box_tracker << i+(m-1)
        end
      end

      point_placemarks = []
      placemark = KML::Placemark.new( :name => c[2] )
      if(!box_tracker.include?(i))
        point_placemarks << KmlTools.cube(cube_coords, 50, Co2ColorCode.insitu_colorify(c[2]), KmlTools.DEFAULT_BOX)
        col = KML::Polygon.new( :outer_boundary_is => KML::LinearRing.new(:coordinates => cube_coords),
                                :altitude_mode => 'absolute', :extrude => true)
        placemark.features << sty << col
        point_placemarks << placemark
        placemarks << [c[4], point_placemarks]
      end
    end
  end
  placemarks
end

def divide_into_minute_folders(placemarks)
  folders = []
  placemarks.in_groups_of(45, false) do |minute|
    folders << KML::Folder.new(
      :name => Time.at(minute[0][0]).strftime("%H:%M %Y-%m-%d"),
      :features => minute.map{|x| cdr(x)}.flatten)
  end
  folders
end

def divide_into_30minute_folders(minute_folders)
  folders = []
  minute_folders.in_groups_of(15, false) do |thirty_minutes|
    folders << KML::Folder.new(
      :name => car(thirty_minutes).name,
      :features => thirty_minutes)
  end
  folders
end
