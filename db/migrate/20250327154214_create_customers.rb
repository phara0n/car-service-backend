class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.text :address
      t.references :user, null: false, foreign_key: true
      t.string :national_id
      t.string :tax_number
      t.string :region_code

      t.timestamps
    end
    add_index :customers, :email
  end
end
