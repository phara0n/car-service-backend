class ServiceSerializer < ApplicationSerializer
  attributes :name, :description, :price, :duration, :active
  
  # Include formatted values for convenience
  attribute :formatted_price do
    object.formatted_price
  end
  
  attribute :formatted_duration do
    object.formatted_duration
  end
end 