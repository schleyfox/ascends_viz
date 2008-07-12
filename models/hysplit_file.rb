class HysplitFile < ActiveRecord::Base
  
  def self.load(files, path)
    files.each do |file|
      date = cdr(/\w{4}\d\.(\w{3})(\d{2})\.\w\d$/.match(file).to_a) rescue nil
      if date.nil?
        puts file
        break
      end
      
      f = HysplitFile.new
      f.file_name = File.basename("#{file}")
      f.path = "#{path}/"
      f.month = DateTime.strptime("#{date.first}", "%b").strftime("%m") rescue puts( file)
      f.year = "20#{date[1]}"
      f.save
    end
  end
end
