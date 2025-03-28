class MileageRecordSerializer < ApplicationSerializer
  attributes :mileage, :recorded_at, :notes
  
  belongs_to :car
  
  def recorded_at
    object.recorded_at.iso8601 if object.recorded_at
  end
  
  # Include car info for convenience
  attribute :car_info do
    {
      id: object.car.id,
      make: object.car.make,
      model: object.car.model,
      year: object.car.year,
      license_plate: object.car.license_plate
    }
  end
end 