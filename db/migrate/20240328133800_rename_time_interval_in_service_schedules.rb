class RenameTimeIntervalInServiceSchedules < ActiveRecord::Migration[7.1]
  def change
    rename_column :service_schedules, :time_interval, :time_interval_months
  end
end 