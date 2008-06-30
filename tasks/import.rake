desc "Import data into the database"
task :import do
  get_db_conn(ENV["GTRON_ENV"] || GTRON_ENV)
  input_path = ENV["INPUT_PATH"] || "#{GTRON_ROOT}/input"

  Flight.delete_all
  DataPoint.delete_all
  Flight.load(Dir.glob("#{input_path}/*"))
end
