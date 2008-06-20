class CreateFlightAndDataPoint < ActiveRecord::Migration
  def self.up
    create_table :flights do |t|
      t.column :date, :string, :limit => (4+1+2+1+2)
      t.integer :flight_number
    end

    create_table :data_points do |t|
      t.integer :flight_id

      t.integer :time
      t.float :lat
      t.float :lon
      t.float :altitude

      t.float :co2_ppm
    end
  end

  def self.down
    drop_table :flights
    drop_table :data_points
  end
end
