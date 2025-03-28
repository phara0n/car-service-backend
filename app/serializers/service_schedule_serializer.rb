class ServiceScheduleSerializer < ApplicationSerializer
  attributes :service_type, :mileage_interval, :time_interval
  
  belongs_to :car
  
  # Include next service predictions
  attribute :next_service_mileage do
    object.next_service_mileage
  end
  
  attribute :next_service_date do
    date = object.next_service_date
    date&.iso8601
  end
  
  attribute :predicted_next_service_date do
    date = object.predicted_next_service_date
    date&.iso8601
  end
  
  # Include mileage-to-go info
  attribute :mileage_to_go do
    next_mileage = object.next_service_mileage
    if next_mileage
      next_mileage - object.car.current_mileage
    else
      nil
    end
  end
  
  # Include days-to-go info
  attribute :days_to_go do
    date = object.predicted_next_service_date || object.next_service_date
    if date
      (date - Date.current).to_i
    else
      nil
    end
  end
end 