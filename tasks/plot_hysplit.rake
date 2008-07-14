desc "Write a task description and write it good!"
task :plot_hysplit do
  get_db_conn(GTRON_ENV)
  FileUtils.rm_r Dir.glob("#{GTRON_ROOT}/output/hysplit/kml/*")
  FileUtils.rm_r Dir.glob("#{GTRON_ROOT}/output/hysplit/plots/*")

  files = Dir.glob("./hysplit_model_output/*")
  files.each do |file|
    `/hysplit4/exec/trajplot -a3 -i#{file} -o./output/hysplit/plots/#{File.basename("#{file}")}`
    `mv ./*.kml ./output/hysplit/kml/#{File.basename("#{file}")}.kml`
  end
end
