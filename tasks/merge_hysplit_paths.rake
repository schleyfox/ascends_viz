require 'hpricot'
desc "Merges HYSPLIT kml files from one date to another"
task :merge_hysplit_paths do
#  get_db_conn(GTRON_ENV)
  kml_files = Dir['output/hysplit/kml'].sort
  if kml_files.size < 1
    puts "Put the files in the right fucking directory dipshit"
    return nil
  end
  if ENV.include?('start_time') and ENV.include?('end_time')
    @start_time, @end_time = ENV['start_time'], ENV['end_time']
  else
    puts "Where's the fucking start_time and end_time in seconds dumbass?"
    return nil
  end
  # Please excuse the terse iterator variables, yes I do realize this isn't 1956
  i, k = kml_files.index(kml_files.detect { |f| f.index(@start_time) }), kml_files.index(kml_files.detect { |f| f.index(@end_time) })
  i..k.each do |j|
    doc = Hpricot.XML(open(kml_files[j]))
    (doc/:LineString).each do |ls|
      puts ls.to_s
    end
  end
end
