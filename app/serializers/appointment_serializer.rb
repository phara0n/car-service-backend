class AppointmentSerializer < ApplicationSerializer
  attributes :date, :time, :status, :notes
  
  belongs_to :customer
  belongs_to :car
  has_many :services
  
  # Format the date and time
  def date
    object.date.iso8601 if object.date
  end
  
  def time
    object.time.strftime("%H:%M") if object.time
  end
  
  # Include calculations for convenience
  attribute :total_duration do
    object.total_duration
  end
  
  attribute :total_price do
    object.total_price
  end
  
  # Include customer and car info for convenience
  attribute :customer_name do
    object.customer.name
  end
  
  attribute :car_info do
    {
      id: object.car.id,
      make: object.car.make,
      model: object.car.model,
      year: object.car.year,
      license_plate: object.car.license_plate
    }
  end
  
  # Include formatted duration and price
  attribute :formatted_duration do
    duration = object.total_duration
    hours = duration / 60
    minutes = duration % 60
    
    if hours > 0
      "#{hours}h#{minutes > 0 ? " #{minutes}m" : ""}"
    else
      "#{minutes}m"
    end
  end
  
  attribute :formatted_price do
    sprintf("%.2f", object.total_price)
  end
end 