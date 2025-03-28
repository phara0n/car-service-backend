class CreateServiceSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :service_schedules do |t|
      t.references :car, null: false, foreign_key: true
      t.string :service_type
      t.integer :mileage_interval
      t.integer :time_interval

      t.timestamps
    end
  end
end
