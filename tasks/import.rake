desc "Import data into the database"
task :import do
  get_db_conn(ENV["GTRON_ENV"] || GTRON_ENV)
  Flight.delete_all
  DataPoint.delete_all
  Flight.load(Dir.glob("#{GTRON_ROOT}/input/*"))
end
