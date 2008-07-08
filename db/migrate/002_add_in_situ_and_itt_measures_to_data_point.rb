class AddInSituAndIttMeasuresToDataPoint < ActiveRecord::Migration
  def self.up
    remove_column :data_points, :co2_ppm
    add_column :data_points, :itt_co2, :float
    add_column :data_points, :insitu_co2, :float
  end

  def self.down
    add_column :data_points, :co2_ppm, :flight
    remove_column :data_points, :itt_co2
    remove_column :data_points, :insitu_co2
  end
end
