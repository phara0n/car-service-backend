class Appointment < ApplicationRecord
  belongs_to :customer
  belongs_to :car
  has_and_belongs_to_many :services
  
  validates :date, presence: true
  validates :time, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending confirmed completed cancelled] }
  
  scope :upcoming, -> { where('date >= ?', Date.current).order(date: :asc, time: :asc) }
  scope :past, -> { where('date < ?', Date.current).order(date: :desc, time: :desc) }
  scope :pending, -> { where(status: 'pending') }
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :completed, -> { where(status: 'completed') }
  scope :cancelled, -> { where(status: 'cancelled') }
  
  # Update car mileage when appointment is completed
  after_update :update_car_mileage, if: -> { saved_change_to_status? && status == 'completed' }
  
  # Calculate total duration of appointment
  def total_duration
    services.sum(:duration)
  end
  
  # Calculate total price of appointment
  def total_price
    services.sum(:price)
  end
  
  private
  
  def update_car_mileage
    # Only update if mileage is recorded in the notes
    # Expected format: "Current mileage: 12345"
    return unless notes.present?
    
    mileage_match = notes.match(/current mileage:\s*(\d+)/i)
    return unless mileage_match
    
    mileage = mileage_match[1].to_i
    
    # Only update if the new mileage is greater than the current mileage
    if mileage > car.current_mileage
      car.update(current_mileage: mileage)
    end
  end
end
