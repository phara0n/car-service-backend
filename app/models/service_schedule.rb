class ServiceSchedule < ApplicationRecord
  belongs_to :car
  
  validates :service_type, presence: true
  validates :mileage_interval, numericality: { greater_than: 0 }, allow_nil: true
  validates :time_interval_months, numericality: { greater_than: 0 }, allow_nil: true
  validate :at_least_one_interval
  
  before_save :calculate_next_service_date
  before_save :calculate_next_service_mileage
  
  # Calculate the next service mileage
  def next_service_mileage
    return nil unless mileage_interval.present?
    
    last_service_record = car.mileage_records.first # Already ordered by recorded_at desc
    last_service_mileage = last_service_record&.mileage || car.initial_mileage
    
    last_service_mileage + mileage_interval
  end
  
  # Calculate the next service date
  def next_service_date
    return nil unless time_interval_months.present?
    
    last_service_date = car.mileage_records.first&.recorded_at&.to_date || car.created_at.to_date
    
    last_service_date + time_interval_months.months
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
  
  def calculate_next_service_date
    return unless car.present?

    last_service = car.appointments
                     .joins(:services)
                     .where(services: { name: service_type })
                     .order(date: :desc)
                     .first

    if last_service
      # If there was a previous service, calculate from that date
      if time_interval_months
        self.next_service_date = last_service.date + time_interval_months.months
      end
    else
      # If no previous service, calculate from today
      if time_interval_months
        self.next_service_date = Date.today + time_interval_months.months
      end
    end

    # If no time interval is set, set next service date to 1 year from now as default
    self.next_service_date ||= Date.today + 1.year
  end

  def calculate_next_service_mileage
    return unless car.present? && mileage_interval.present?

    last_service = car.appointments
                     .joins(:services)
                     .where(services: { name: service_type })
                     .order(date: :desc)
                     .first

    if last_service
      # If there was a previous service, calculate from that mileage
      last_mileage = car.mileage_records
                       .where('recorded_at <= ?', last_service.date)
                       .order(recorded_at: :desc)
                       .first&.mileage || car.initial_mileage

      self.next_service_mileage = last_mileage + mileage_interval
    else
      # If no previous service, calculate from current mileage
      self.next_service_mileage = car.current_mileage + mileage_interval
    end
  end
  
  def at_least_one_interval
    if mileage_interval.nil? && time_interval_months.nil?
      errors.add(:base, "At least one of mileage_interval or time_interval_months must be set")
    end
  end
end
