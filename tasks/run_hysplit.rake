desc "The name says it."
task :run_hysplit do
  run_time = 72 #how long you want the model to run for
  
  get_db_conn(GTRON_ENV)
  `rm ./hysplit_model_output/*`
  
  data = DataPoint.find(:all)
  
  data.each do |point|
    if (point.time % 120 == 0)
      control = File.open("./CONTROL", "w")
      start_time = Time.at(point.time)
      control << "#{start_time.year} #{start_time.month} #{start_time.day} #{start_time.hour}\n"
      control << "1\n"
      control << "#{point.lat} #{point.lon} #{point.altitude}\n"
      control << run_time.to_s + "\n" + "0\n10000.0\n" # This line is doing the run_time, and a few other constants
      hysplit_files = HysplitFile.find(:all, :conditions => "month = #{start_time.month} AND year = #{start_time.year}")
      control << hysplit_files.size.to_s + "\n"
      hysplit_files.each do |file|
        control << file.path.to_s + "\n" + file.file_name.to_s + "\n"
      end
      control << "./hysplit_model_output/\n#{point.time}\n"
      control.close
      `/hysplit4/exec/hymodelt`
    end
  end
end
