# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create superadmin user
superadmin = User.find_or_create_by(email: 'superadmin@example.com') do |user|
  user.name = 'Super Admin'
  user.role = 'superadmin'
  user.is_superadmin = true
  user.password = 'password123'
  user.password_confirmation = 'password123'
end
puts "Created superadmin user: #{superadmin.email}"

# Create admin user
admin = User.find_or_create_by(email: 'admin@example.com') do |user|
  user.name = 'Admin User'
  user.role = 'admin'
  user.is_superadmin = false
  user.password = 'password123'
  user.password_confirmation = 'password123'
end
puts "Created admin user: #{admin.email}"

# Create standard services
standard_services = [
  { name: 'Oil Change', description: 'Full synthetic oil change service', price: 120.00, duration: 45 },
  { name: 'Brake Service', description: 'Brake pad replacement and rotor inspection', price: 250.00, duration: 90 },
  { name: 'Tire Rotation', description: 'Rotate and balance all tires', price: 80.00, duration: 45 },
  { name: 'Engine Tune-up', description: 'Complete engine tune-up service', price: 300.00, duration: 120 }
]

# Create Tunisian-specific services
tunisian_services = [
  { name: 'Visite Technique', description: 'Technical inspection required by Tunisian law', price: 80.00, duration: 60 },
  { name: 'Renouvellement de Vignette', description: 'Road tax renewal service', price: 45.00, duration: 30 },
  { name: 'Renouvellement d\'Assurance', description: 'Insurance renewal assistance', price: 60.00, duration: 45 }
]

# Create all services
(standard_services + tunisian_services).each do |service_data|
  Service.find_or_create_by!(name: service_data[:name]) do |service|
    service.description = service_data[:description]
    service.price = service_data[:price]
    service.duration = service_data[:duration]
  end
end

# Create sample customers
10.times do |i|
  user = User.create!(
    email: "customer#{i+1}@example.com",
    password: 'password123',
    password_confirmation: 'password123',
    name: "Customer #{i+1}",
    role: 'customer'
  )

  customer = Customer.create!(
    name: user.name,
    email: user.email,
    phone: "+216 #{rand(10_000_000..99_999_999)}",
    address: "#{rand(1..100)} Rue #{['Habib Bourguiba', 'Ibn Khaldoun', 'Charles de Gaulle'].sample}, #{['Tunis', 'Sfax', 'Sousse'].sample}",
    national_id: rand(10_000_000..99_999_999).to_s,
    tax_number: rand(1_000_000..9_999_999).to_s,
    region_code: ['TUN', 'SFA', 'SOU'].sample,
    user: user
  )

  # Create 1-3 cars for each customer
  rand(1..3).times do
    car = Car.create!(
      customer: customer,
      make: ['Peugeot', 'Volkswagen', 'Renault', 'Citroën', 'Fiat'].sample,
      model: ['208', 'Golf', 'Clio', 'C3', '500'].sample,
      year: rand(2015..2024),
      vin: SecureRandom.hex(8).upcase,
      license_plate: "#{rand(1..199)} TU #{rand(1000..9999)}",
      initial_mileage: rand(0..50000),
      current_mileage: rand(50001..100000),
      customs_clearance_number: "TN-#{rand(2015..2024)}-#{rand(10000..99999)}",
      technical_visit_date: Date.today + rand(-180..180),
      insurance_category: ['A', 'B', 'C'].sample
    )

    # Create service schedules for the car
    ['Oil Change', 'Tire Rotation', 'Brake Service', 'Visite Technique'].each do |service_name|
      ServiceSchedule.create!(
        car: car,
        service_type: service_name,
        mileage_interval: case service_name
                         when 'Oil Change' then 10000
                         when 'Tire Rotation' then 20000
                         when 'Brake Service' then 40000
                         when 'Visite Technique' then nil
                         end,
        time_interval_months: case service_name
                            when 'Oil Change' then 6
                            when 'Tire Rotation' then 12
                            when 'Brake Service' then 24
                            when 'Visite Technique' then 12
                            end
      )
    end
  end
end

# Get references for creating appointments
services = Service.all
customers = Customer.all
cars = Car.all

# Create sample appointments for the next 30 days
30.times do
  customer = customers.sample
  car = customer.cars.sample
  
  # Random appointment date within next 30 days
  date = Date.today + rand(0..30)
  
  # Random time between 8 AM and 5 PM
  time = Time.new(2000, 1, 1, rand(8..16), [0, 30].sample, 0)
  
  # Create appointment with 1-3 random services
  appointment = Appointment.create!(
    customer: customer,
    car: car,
    date: date,
    time: time,
    status: ['scheduled', 'in_progress', 'completed'].sample,
    notes: ['Regular maintenance', 'Customer reported issues', 'Follow-up service'].sample
  )
  
  # Add random services to appointment (avoiding duplicates)
  services.sample(rand(1..3)).each do |service|
    appointment.services << service unless appointment.services.include?(service)
  end
end

# Create some completed appointments in the past for history
15.times do
  customer = customers.sample
  car = customer.cars.sample
  
  # Random appointment date within last 30 days
  date = Date.today + rand(-30..-1)
  
  # Random time between 8 AM and 5 PM
  time = Time.new(2000, 1, 1, rand(8..16), [0, 30].sample, 0)
  
  # Create completed appointment
  appointment = Appointment.create!(
    customer: customer,
    car: car,
    date: date,
    time: time,
    status: 'completed',
    notes: ['Regular maintenance completed', 'Issues resolved', 'Service completed successfully'].sample
  )
  
  # Add random services to appointment (avoiding duplicates)
  services.sample(rand(1..3)).each do |service|
    appointment.services << service unless appointment.services.include?(service)
  end
end

# Update cars with mileage records
cars.each do |car|
  last_mileage = car.initial_mileage
  
  # Create 3-5 mileage records per car
  rand(3..5).times do
    recorded_at = Time.current + rand(-180..0).days
    new_mileage = last_mileage + rand(1000..5000)
    
    MileageRecord.create!(
      car: car,
      mileage: new_mileage,
      recorded_at: recorded_at,
      notes: ['Regular update', 'Service check', 'Customer reported'].sample
    )
    
    last_mileage = new_mileage
  end
  
  # Update car's current mileage
  car.update!(current_mileage: last_mileage)
end

puts "Seed data created successfully!"
puts "Created #{Service.count} services"
puts "Created #{Customer.count} customers"
puts "Created #{Car.count} cars"
puts "Created #{ServiceSchedule.count} service schedules"
puts "Created #{Appointment.count} appointments"
puts "Created #{MileageRecord.count} mileage records"
