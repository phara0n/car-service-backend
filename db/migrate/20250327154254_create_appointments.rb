class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :car, null: false, foreign_key: true
      t.date :date
      t.time :time
      t.string :status
      t.text :notes

      t.timestamps
    end
  end
end
