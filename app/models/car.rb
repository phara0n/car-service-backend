class Car < ApplicationRecord
  belongs_to :customer
  has_many :mileage_records, dependent: :destroy
  has_many :service_schedules, dependent: :destroy
  has_many :appointments, dependent: :destroy
  
  validates :make, :model, :year, :vin, :license_plate, presence: true
  validates :initial_mileage, :current_mileage, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :year, numericality: { only_integer: true, greater_than: 1900, less_than_or_equal_to: -> { Date.current.year + 1 } }
  validates :vin, uniqueness: true
  validates :license_plate, uniqueness: true
  
  # Validate that current_mileage is not less than initial_mileage
  validate :current_mileage_not_less_than_initial
  # Validate that current_mileage is not less than previous record
  validate :current_mileage_not_less_than_previous, on: :update
  
  # Tunisian specific validations
  validates :customs_clearance_number, presence: true, if: :requires_tunisian_fields?
  validates :technical_visit_date, presence: true, if: :requires_tunisian_fields?
  
  # Create initial mileage record after create
  after_create :create_initial_mileage_record
  # Update mileage records after current_mileage is updated
  after_update :update_mileage_records, if: :saved_change_to_current_mileage?
  
  # Calculate average daily mileage
  def average_daily_mileage
    return 0 if mileage_records.count < 2
    
    first_record = mileage_records.order(:recorded_at).first
    last_record = mileage_records.order(:recorded_at).last
    
    mileage_diff = last_record.mileage - first_record.mileage
    days_diff = (last_record.recorded_at.to_date - first_record.recorded_at.to_date).to_i
    
    return 0 if days_diff == 0
    
    mileage_diff / days_diff
  end
  
  private
  
  def requires_tunisian_fields?
    # This should check if the app is configured for Tunisian market
    # For now, we'll use the presence of other Tunisian fields
    customs_clearance_number.present? || technical_visit_date.present? || insurance_category.present?
  end
  
  def current_mileage_not_less_than_initial
    if current_mileage.present? && initial_mileage.present? && current_mileage < initial_mileage
      errors.add(:current_mileage, "cannot be less than initial mileage")
    end
  end
  
  def current_mileage_not_less_than_previous
    if current_mileage_was.present? && current_mileage.present? && current_mileage < current_mileage_was
      errors.add(:current_mileage, "cannot be less than previous mileage")
    end
  end
  
  def create_initial_mileage_record
    mileage_records.create(
      mileage: initial_mileage,
      recorded_at: Time.current,
      notes: "Initial mileage record"
    )
  end
  
  def update_mileage_records
    mileage_records.create(
      mileage: current_mileage,
      recorded_at: Time.current,
      notes: "Updated via current_mileage field"
    ) if saved_change_to_current_mileage?
  end
end
