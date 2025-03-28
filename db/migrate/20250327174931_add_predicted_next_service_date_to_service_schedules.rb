class AddPredictedNextServiceDateToServiceSchedules < ActiveRecord::Migration[8.0]
  def change
    add_column :service_schedules, :predicted_next_service_date, :date
  end
end
