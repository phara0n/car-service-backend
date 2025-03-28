class CreateMileageRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :mileage_records do |t|
      t.references :car, null: false, foreign_key: true
      t.datetime :recorded_at
      t.integer :mileage
      t.text :notes

      t.timestamps
    end
  end
end
