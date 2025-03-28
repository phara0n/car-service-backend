class ServiceSchedule < ApplicationRecord
  belongs_to :car
  
  validates :service_type, presence: true
  validates :mileage_interval, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :time_interval, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :at_least_one_interval
  
  # Calculate the next service mileage
  def next_service_mileage
    return nil unless mileage_interval.present?
    
    last_service_record = car.mileage_records.first # Already ordered by recorded_at desc
    last_service_mileage = last_service_record&.mileage || car.initial_mileage
    
    last_service_mileage + mileage_interval
  end
  
  # Calculate the next service date
  def next_service_date
    return nil unless time_interval.present?
    
    last_service_date = car.mileage_records.first&.recorded_at&.to_date || car.created_at.to_date
    
    last_service_date + time_interval.days
  end
  
  # Predict next service based on mileage accumulation rate
  def predicted_next_service_date
    return next_service_date unless mileage_interval.present?
    
    daily_mileage = car.average_daily_mileage
    return nil if daily_mileage == 0
    
    mileage_to_go = next_service_mileage - car.current_mileage
    days_to_go = (mileage_to_go / daily_mileage).ceil
    
    Date.current + days_to_go.days
  end
  
  private
  
  def at_least_one_interval
    if mileage_interval.nil? && time_interval.nil?
      errors.add(:base, "At least one of mileage interval or time interval must be specified")
    end
  end
end
