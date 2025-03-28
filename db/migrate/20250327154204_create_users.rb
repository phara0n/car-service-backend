class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :role
      t.string :name
      t.boolean :is_superadmin

      t.timestamps
    end
    add_index :users, :email
  end
end
