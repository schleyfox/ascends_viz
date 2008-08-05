desc "Import emitters from text file specified by FILE"
task :import_emitters do
  get_db_conn(GTRON_ENV)
  return nil unless ENV['FILE']
  Emitter.from_file(ENV['FILE'])
end
