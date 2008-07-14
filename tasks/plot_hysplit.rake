desc "Write a task description and write it good!"
task :plot_hysplit do
  get_db_conn(GTRON_ENV)
  `rm ./hysplit_model_output/plots/*`
  `rm ./hysplit_model_output/kml/*`
  files = Dir.glob("./hysplit_model_output/*")
  files.each do |file|
    `/hysplit4/exec/trajplot -a3 -i#{file} -o./hysplit_model_output/plots/#{File.basename("#{file}")}`
    `mv ./*.kml ./hysplit_model_output/kml/#{File.basename("#{file}")}.kml`
  end
end
