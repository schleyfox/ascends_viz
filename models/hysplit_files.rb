class HysplitFiles < ActiveRecord::Base
  
  def self.load(files, path)
    files.each do |file|
      f = HysplitFiles.new
      f.file_name = File.basename("#{file}")
      f.path = path + "/"
      f.save
    end
  end
end
