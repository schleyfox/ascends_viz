require 'hpricot'

desc "Merges HYSPLIT kml files from one date to another"
task :merge_hysplit_paths do
  get_db_conn(GTRON_ENV)
  
  MERGED_DIR = "output/hysplit/kml/merged/"
  KML_DIR = "output/hysplit/kml/"
  
  FileUtils.rm Dir["#{MERGED_DIR}*"], :force => true
  TOLERANCE = ENV['tolerance'] || 10
  
  Dir.mkdir(MERGED_DIR) unless File.exists?(MERGED_DIR) && File.directory?(MERGED_DIR) 
  
  kml_files = Dir["#{KML_DIR}*.kml"].sort
  if kml_files.size < 1
    puts "Make sure the HYSPLIT KML files are in the right directory."
    return nil
  end
  
  # Please excuse the terse iterator variables, yes I do realize this isn't 1956
kml_files.each do |j| doc = Hpricot.XML(open("#{Dir.getwd}/#{j}"))
  (doc/:LineString).each do |ls|
    coords = (ls/:coordinates).to_s.split("\n")[1].strip.split(",")
    time = /\/(\d+).kml$/.match(j)
    next unless time
    time = time[1].to_i
    dp = DataPoint.find(:first, :conditions => {:time => time})
    (1..TOLERANCE).each do |t|
      next if dp
      dp = DataPoint.find(:first, :conditions => {:time => time+t})
      dp = DataPoint.find(:first, :conditions => {:time => time+(-1*t)}) unless dp
    end
    merged_kml = "#{MERGED_DIR}flight_#{dp.flight.flight_number}.kml"
    placemark = KML::Placemark.new(:name => "Merged HYSPLIT for Flight #{dp.flight.flight_number}", :description => Time.at(dp.time).strftime("%H:%M %Y-%m-%d"))
    style = KML::Style.new(:poly_style => KML::PolyStyle.new(:color => Co2ColorCode.itt_colorify(dp.co2), :outline => false))
    placemark.features << style
    placemark.plain_children << Hpricot.uxs(ls.to_s)
    open(merged_kml, 'w') do |f|
      kml = KMLFile.new
      kml.objects << KML::Document.new(:name => "Merged HYSPLIT Paths")
      f.write(kml.render)
    end unless File.exists?(merged_kml)
    f = open(merged_kml, 'r+')
    fr = f.readlines.join()
    txt = placemark.render.to_s
    h = Hpricot.XML(fr) # Need to check for already merged?
    (h/:Document).append(txt)
    f.reopen(merged_kml, "w+")
    f.write(h.to_s)
    f.close
  end
end
end
