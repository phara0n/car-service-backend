class AddAverageDailyMileageToCars < ActiveRecord::Migration[8.0]
  def change
    add_column :cars, :average_daily_mileage, :float
  end
end
