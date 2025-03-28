class AddNextServiceMileageToServiceSchedules < ActiveRecord::Migration[7.1]
  def change
    add_column :service_schedules, :next_service_mileage, :integer
    add_index :service_schedules, :next_service_mileage
  end
end 