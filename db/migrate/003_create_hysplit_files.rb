class CreateHysplitFiles < ActiveRecord::Migration
  def self.up
    create_table :hysplit_files do |t|
      t.string :path
      t.string :file_name
      t.string :month
      t.integer :year
    end
  end

  def self.down
    drop_table :hysplit_files
  end
end
