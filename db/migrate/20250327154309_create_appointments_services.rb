class CreateAppointmentsServices < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments_services do |t|
      t.references :appointment, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true

      t.timestamps
    end
  end
end
