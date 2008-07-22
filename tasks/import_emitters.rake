desc "Import emitters from text file"
task :import_emitters do
  get_db_conn(GTRON_ENV)
  return nil unless ENV['file']
  Emitter.from_file(ENV['file'])
end
