class CarSerializer < ApplicationSerializer
  attributes :make, :model, :year, :vin, :license_plate, 
             :initial_mileage, :current_mileage, 
             :customs_clearance_number, :technical_visit_date, :insurance_category
  
  belongs_to :customer
  has_many :mileage_records
  has_many :service_schedules
  has_many :appointments
  
  # Format the technical visit date
  def technical_visit_date
    object.technical_visit_date&.iso8601
  end
  
  # Include the customer name for convenience
  attribute :customer_name do
    object.customer.name
  end
  
  # Calculate the average daily mileage
  attribute :average_daily_mileage do
    object.average_daily_mileage
  end
  
  # Include the latest mileage record
  attribute :latest_mileage_record do
    latest = object.mileage_records.first
    if latest
      {
        id: latest.id,
        mileage: latest.mileage,
        recorded_at: latest.recorded_at.iso8601,
        notes: latest.notes
      }
    else
      nil
    end
  end
end 