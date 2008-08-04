require 'hpricot'

desc "Runs and merges all of the visualization tasks together"
task :complete_visualization do
  get_db_conn(GTRON_ENV)

  hysplit_filenames = Dir.glob(
    "#{GTRON_ROOT}/output/hysplit/kml/merged/flight_*.kml")
  hysplit = Hash[*hysplit_filenames.map{|f| hysplit_flight(f) }.flatten]

  co2_filename = "#{GTRON_ROOT}/output/co2_columns.kml"
  co2 = Hpricot.XML(File.read(co2_filename))
  
  make_hysplit_and_co2_folders(co2)

  merge_hysplit_with_co2(hysplit, co2)

  color_bar_filename = "#{GTRON_ROOT}/output/co2_color_bar.kml"
  color_bar = Hpricot.XML(File.read(color_bar_filename))

  (co2/"/kml/Document").append((color_bar/"/kml/Document/ScreenOverlay").to_html)
  
  puts co2.to_html.split("\n").delete_if{|l| /^\s*$/.match(l) }.join("\n")

end

def hysplit_flight(filename)
  flight_number = /flight_(\d+)/.match(filename)[1].to_i
  flight_xml = Hpricot.XML(File.read(filename))
  
  [flight_number, hysplit_flight_data(flight_xml)]
  #rescue NoMethodError
  #  raise("Invalid Merged HYSPLIT filename")
end

def hysplit_flight_data(xml)
 Hash[*(xml/"kml/Document/Placemark").map do |placemark|
   time = kmltime((placemark/:description).text)
   placemark.inner_html = placemark.inner_html + "<visibility>0</visibility>"
   placemark_xml = placemark.to_s
   [time, placemark_xml]
 end.flatten]
end

def make_hysplit_and_co2_folders(co2)
  (co2/"kml/Document/Folder").each do |flight|
    (flight/"/Folder").each do |thirty_min|
      (thirty_min/"/Folder").each do |minute|
        co2_fold = KML::Folder.new(:name => 'CO2')
        co2_fold = (Hpricot.XML(co2_fold.render)/:Folder)
        co2_fold.append((minute/:Placemark).to_html)
        (minute/:Placemark).remove
        minute.inner_html = minute.inner_html + co2_fold.to_html

        hy_fold = KML::Folder.new(:name => 'HYSPLIT', :visibility => false)
        minute.inner_html = minute.inner_html + (hy_fold.render.strip)

      end
    end
  end
end

def merge_hysplit_with_co2(hysplit, co2)
  (co2/"kml/Document/Folder").each do |flight|
    flight_number = (flight.at(:name)).inner_html[/Flight (\d+)/,1].to_i
    return unless flight_number

    curr_hysplit = hysplit[flight_number]


    time_ranges = time_ary_to_time_range(folders_to_time_ary(flight))
    time_ranges.each do |time_range|
      hysplit_point = curr_hysplit.first

      while time_range[0].include? hysplit_point[0]
        time_range[1].inner_html = time_range[1].inner_html + hysplit_point[1]

        curr_hysplit.delete(hysplit_point[0])
        hysplit_point = curr_hysplit.first
      end
    end
  end
end

def folders_to_time_ary(folders)
  minutes = (folders/"/Folder/Folder")
  minutes.map do |minute|
    [kmltime((minute/"/name").inner_text), get_hysplit_folder(minute)]
  end.sort
end

def time_ary_to_time_range(time_ary)
  time_ranges = []
  for i in (0...time_ary.size-1)
    time_ranges << [(time_ary[i][0]...time_ary[i+1][0]),
      time_ary[i][1]]
  end
  time_ranges
end

def get_hysplit_folder(folder)
  folders = folder/"/Folder"
  folders.detect do |f|
    (f/"/name").inner_text == "HYSPLIT"
  end
end
    


def kmltime(string)
  string.strip!
  d = DateTime.strptime(string, "%H:%M %Y-%m-%d") rescue puts(string)
  Time.local(d.year, d.month, d.day, d.hour, d.min).to_i
end

