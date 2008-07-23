class Emitter < ActiveRecord::Base

  def self.from_file(file)
    return nil unless File.exists?(file)
    params, state, e = {}
    open(file,"r") do |f|
      until state
        line = f.readline
        state = line if line.size == 3
      end
      until f.eof?
        line = f.readline.split(",")
        next unless line.size > 1
        params = {:name => line[0], :lat => line[1], :lon => line[2], 
                  :energy_source => line[3].strip, :energy_source_secondary => nil,
                  :capacity => line[5], :state => state.strip }
        params[:energy_source_secondary] = line[4].strip if line[4]
        e = Emitter.create(params)
      end
    end
  end

  def pos_to_tuple
    [lon,lat, 0]
  end

end
