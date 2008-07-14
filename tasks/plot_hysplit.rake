desc "Write a task description and write it good!"
task :plot_hyplit do
  get_db_conn(GTRON_ENV)
  files = Dir.glob("./hysplit_dump/*")
  files.each do |file|
    `/hysplit4/exec/trajplot -a3 -i#{file} -o./hysplit_dump/test/#{File.basename("#{file}")}`
    `mv ./*.kml ./hysplit_dump/kml/#{File.basename("#{file}")}.kml`
  end
end
