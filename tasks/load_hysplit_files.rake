desc "Load all hysplit file information into the database."
task :load_hysplit_files do
  get_db_conn(GTRON_ENV)
  hysplit_path = ENV["HYSPLIT_PATH"] || "#{GTRON_ROOT}/hysplit"
  
  HysplitFile.delete_all
  HysplitFile.load(Dir.glob("#{hysplit_path}/*"), hysplit_path)
end
