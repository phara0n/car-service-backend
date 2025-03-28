class AddActiveToServices < ActiveRecord::Migration[8.0]
  def change
    add_column :services, :active, :boolean
  end
end
