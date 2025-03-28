class AddNextServiceDateToServiceSchedules < ActiveRecord::Migration[7.1]
  def change
    add_column :service_schedules, :next_service_date, :date
    add_index :service_schedules, :next_service_date
  end
end 