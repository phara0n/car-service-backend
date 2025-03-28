class CustomerSerializer < ApplicationSerializer
  attributes :name, :email, :phone, :address, :national_id, :tax_number, :region_code
  
  belongs_to :user
  has_many :cars
  
  # Include count of cars to avoid N+1 queries
  attribute :cars_count do
    object.cars.size
  end
end 