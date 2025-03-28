class MileageRecord < ApplicationRecord
  belongs_to :car
  
  validates :mileage, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :recorded_at, presence: true
  
  validate :mileage_not_less_than_previous
  
  default_scope { order(recorded_at: :desc) }
  
  private
  
  def mileage_not_less_than_previous
    return if car.nil? || mileage.nil?
    
    previous_record = car.mileage_records.where('recorded_at < ?', recorded_at || Time.current).order(recorded_at: :desc).first
    
    if previous_record && mileage < previous_record.mileage
      errors.add(:mileage, "cannot be less than previous mileage (#{previous_record.mileage})")
    end
  end
end
