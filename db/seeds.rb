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

# Create common services
services = [
  { name: 'Oil Change', description: 'Full synthetic oil change', price: 49.99, duration: 30, active: true },
  { name: 'Tire Rotation', description: 'Rotate and balance all tires', price: 29.99, duration: 45, active: true },
  { name: 'Brake Inspection', description: 'Full inspection of brake system', price: 39.99, duration: 60, active: true },
  { name: 'Full Service', description: 'Complete car check-up and maintenance', price: 199.99, duration: 180, active: true },
  { name: 'Air Filter Replacement', description: 'Replace engine air filter', price: 19.99, duration: 15, active: true },
  { name: 'Cabin Filter Replacement', description: 'Replace cabin air filter', price: 24.99, duration: 20, active: true },
  { name: 'Transmission Fluid Change', description: 'Replace transmission fluid', price: 129.99, duration: 60, active: true },
  { name: 'Coolant Flush', description: 'Flush and replace coolant', price: 89.99, duration: 45, active: true },
  { name: 'Wiper Blade Replacement', description: 'Replace front and rear wiper blades', price: 29.99, duration: 15, active: true }
]

services.each do |service_attrs|
  service = Service.find_or_create_by(name: service_attrs[:name]) do |s|
    s.description = service_attrs[:description]
    s.price = service_attrs[:price]
    s.duration = service_attrs[:duration]
    s.active = service_attrs[:active]
  end
  puts "Created service: #{service.name}"
end

# Create 3 sample customers with cars
3.times do |i|
  # Create user for customer
  user = User.find_or_create_by(email: "customer#{i+1}@example.com") do |u|
    u.name = "Customer #{i+1}"
    u.role = 'customer'
    u.is_superadmin = false
    u.password = 'password123'
    u.password_confirmation = 'password123'
  end
  
  # Create customer
  customer = Customer.find_or_create_by(email: user.email) do |c|
    c.name = user.name
    c.phone = "555-123-#{1000 + i}"
    c.address = "#{100 + i} Main St, Anytown, AN"
    c.user = user
    c.national_id = (10000000 + i).to_s
    c.tax_number = (1000000 + i).to_s
    c.region_code = "TUN#{i+1}"
  end
  puts "Created customer: #{customer.name}"
  
  # Create 2 cars for each customer
  2.times do |j|
    car = Car.find_or_create_by(
      customer: customer,
      license_plate: "ABC-#{100 + i}#{j}"
    ) do |c|
      c.make = ['Toyota', 'Honda', 'Ford', 'Volkswagen', 'BMW'].sample
      c.model = ['Corolla', 'Civic', 'F-150', 'Golf', '3-Series'].sample
      c.year = rand(2010..2023)
      c.vin = "VIN#{i}#{j}#{SecureRandom.hex(8)}"
      c.initial_mileage = rand(10000..50000)
      c.current_mileage = rand(c.initial_mileage..(c.initial_mileage + 20000))
      c.customs_clearance_number = "CC#{i}#{j}#{rand(10000..99999)}"
      c.technical_visit_date = Date.today + rand(30..180).days
      c.insurance_category = ['A', 'B', 'C'].sample
    end
    puts "Created car: #{car.make} #{car.model} (#{car.year}) for #{customer.name}"
    
    # Create service schedules for each car
    ['Oil Change', 'Tire Rotation', 'Brake Inspection'].each do |service_type|
      schedule = ServiceSchedule.find_or_create_by(
        car: car,
        service_type: service_type
      ) do |s|
        s.mileage_interval = case service_type
                            when 'Oil Change' then 5000
                            when 'Tire Rotation' then 10000
                            when 'Brake Inspection' then 15000
                            end
        s.time_interval = case service_type
                        when 'Oil Change' then 90
                        when 'Tire Rotation' then 180
                        when 'Brake Inspection' then 365
                        end
      end
      puts "Created service schedule: #{schedule.service_type} for #{car.make} #{car.model}"
    end
    
    # Create an appointment for each car
    status = ['pending', 'confirmed', 'completed', 'cancelled'].sample
    appointment = Appointment.find_or_create_by(
      customer: customer,
      car: car,
      date: Date.today + rand(-30..30).days,
      time: Time.parse("#{rand(8..17)}:00"),
      status: status,
      notes: status == 'completed' ? "Current mileage: #{car.current_mileage + rand(100..500)}" : nil
    )
    
    # Add services to appointment
    services_to_add = Service.all.sample(rand(1..3))
    appointment.services << services_to_add
    
    puts "Created appointment for #{car.make} #{car.model} with #{appointment.services.count} services"
  end
end

puts "Seeding completed!"
