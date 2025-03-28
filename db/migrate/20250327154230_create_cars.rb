class CreateCars < ActiveRecord::Migration[8.0]
  def change
    create_table :cars do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :make
      t.string :model
      t.integer :year
      t.string :vin
      t.string :license_plate
      t.integer :initial_mileage
      t.integer :current_mileage
      t.string :customs_clearance_number
      t.date :technical_visit_date
      t.string :insurance_category

      t.timestamps
    end
    add_index :cars, :vin
  end
end
