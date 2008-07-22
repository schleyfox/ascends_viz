class CreateEmitters < ActiveRecord::Migration
  def self.up
    create_table :emitters do |t|
      t.string :name, :null => false
      t.float :lat, :null => false
      t.float :lon, :null => false
      t.string :energy_source, :limit => 5, :null=>false
      t.string :energy_source_secondary, :limit=>5
      t.float :capacity, :null => false #MWe
      t.string :state, :limit => 2 #Abbreviations ftw
    end
  end

  def self.down
    drop_table :emitter
  end
end
