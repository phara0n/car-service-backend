# Custom seed file for Tunisian market data
# This can be run using: rails runner db/tunisian_seeds.rb

puts "Creating Tunisian market data..."

# Create services specific to Tunisian market
puts "Creating Tunisian-specific services..."

visite_technique = Service.find_or_create_by(name: "Visite Technique") do |service|
  service.description = "Mandatory technical inspection required by Tunisian law"
  service.price = 80.00
  service.duration = 60 # minutes
end

vignette_renewal = Service.find_or_create_by(name: "Renouvellement de Vignette") do |service|
  service.description = "Annual road tax sticker renewal service"
  service.price = 45.00
  service.duration = 30 # minutes
end

assurance_renewal = Service.find_or_create_by(name: "Renouvellement d'Assurance") do |service|
  service.description = "Insurance renewal assistance for Tunisian vehicles"
  service.price = 60.00
  service.duration = 45 # minutes
end

# First create users, then customers
puts "Creating Tunisian users and customers..."

# Tunisian Customer 1
user1 = User.find_or_create_by(email: "amine.bensalah@example.com") do |user|
  user.name = "Amine Ben Salah"
  user.role = "customer"
  user.password = "password123"
  user.password_confirmation = "password123"
end

tunisian_customer1 = Customer.find_or_create_by(email: user1.email) do |customer|
  customer.user = user1
  customer.name = user1.name
  customer.phone = "+216 52 123 456"
  customer.address = "15 Rue Ibn Khaldoun, Tunis 1002"
  customer.national_id = "09876543"
  customer.tax_number = "123456"
  customer.region_code = "TUN"
end

# Tunisian Customer 2
user2 = User.find_or_create_by(email: "leila.trabelsi@example.com") do |user|
  user.name = "Leila Trabelsi"
  user.role = "customer"
  user.password = "password123"
  user.password_confirmation = "password123"
end

tunisian_customer2 = Customer.find_or_create_by(email: user2.email) do |customer|
  customer.user = user2
  customer.name = user2.name
  customer.phone = "+216 98 765 432"
  customer.address = "7 Avenue Habib Bourguiba, Sousse 4000"
  customer.national_id = "12345678"
  customer.tax_number = "789012"
  customer.region_code = "SOU"
end

# Tunisian Customer 3
user3 = User.find_or_create_by(email: "karim.mahjoub@example.com") do |user|
  user.name = "Karim Mahjoub"
  user.role = "customer"
  user.password = "password123"
  user.password_confirmation = "password123"
end

tunisian_customer3 = Customer.find_or_create_by(email: user3.email) do |customer|
  customer.user = user3
  customer.name = user3.name
  customer.phone = "+216 55 987 654"
  customer.address = "22 Rue de Marseille, Sfax 3000"
  customer.national_id = "87654321"
  customer.tax_number = "345678"
  customer.region_code = "SFA"
end

# Create cars for Tunisian customers with Tunisian-specific details
puts "Creating cars for Tunisian customers..."

# Cars for Tunisian Customer 1
car1_customer1 = Car.find_or_create_by(license_plate: "12 TU 3456") do |car|
  car.customer_id = tunisian_customer1.id
  car.make = "Peugeot"
  car.model = "208"
  car.year = 2018
  car.vin = "TUNVIN45678912345"
  car.initial_mileage = 35000
  car.current_mileage = 65000
  car.customs_clearance_number = "TN-2018-56789"
  car.technical_visit_date = Date.today + 2.months
  car.insurance_category = "A"
end

car2_customer1 = Car.find_or_create_by(license_plate: "15 TU 7890") do |car|
  car.customer_id = tunisian_customer1.id
  car.make = "Volkswagen"
  car.model = "Polo"
  car.year = 2019
  car.vin = "TUNVIN98765432109"
  car.initial_mileage = 15000
  car.current_mileage = 42000
  car.customs_clearance_number = "TN-2019-67890"
  car.technical_visit_date = Date.today + 5.months
  car.insurance_category = "B"
end

# Cars for Tunisian Customer 2
car1_customer2 = Car.find_or_create_by(license_plate: "200 TU 123") do |car|
  car.customer_id = tunisian_customer2.id
  car.make = "Renault"
  car.model = "Symbol"
  car.year = 2017
  car.vin = "TUNVIN23456789012"
  car.initial_mileage = 45000
  car.current_mileage = 85000
  car.customs_clearance_number = "TN-2017-12345"
  car.technical_visit_date = Date.today + 1.month
  car.insurance_category = "A"
end

car2_customer2 = Car.find_or_create_by(license_plate: "220 TU 456") do |car|
  car.customer_id = tunisian_customer2.id
  car.make = "Dacia"
  car.model = "Logan"
  car.year = 2020
  car.vin = "TUNVIN34567890123"
  car.initial_mileage = 10000
  car.current_mileage = 30000
  car.customs_clearance_number = "TN-2020-23456"
  car.technical_visit_date = Date.today + 8.months
  car.insurance_category = "C"
end

# Cars for Tunisian Customer 3
car1_customer3 = Car.find_or_create_by(license_plate: "300 TU 789") do |car|
  car.customer_id = tunisian_customer3.id
  car.make = "Citroën"
  car.model = "C3"
  car.year = 2016
  car.vin = "TUNVIN45678901234"
  car.initial_mileage = 55000
  car.current_mileage = 105000
  car.customs_clearance_number = "TN-2016-34567"
  car.technical_visit_date = Date.today - 1.month
  car.insurance_category = "A"
end

# Create initial mileage records for each car if they don't exist
puts "Creating mileage records for Tunisian cars..."

# Only create these if they don't exist
unless MileageRecord.exists?(car_id: car1_customer1.id, mileage: 35000)
  MileageRecord.create!(
    car_id: car1_customer1.id,
    mileage: 35000,
    recorded_at: 2.years.ago,
    notes: "Initial mileage record"
  )
end

unless MileageRecord.exists?(car_id: car1_customer1.id, mileage: 45000)
  MileageRecord.create!(
    car_id: car1_customer1.id,
    mileage: 45000,
    recorded_at: 1.year.ago,
    notes: "Annual service check"
  )
end

unless MileageRecord.exists?(car_id: car1_customer1.id, mileage: 65000)
  MileageRecord.create!(
    car_id: car1_customer1.id,
    mileage: 65000,
    recorded_at: Date.today,
    notes: "Current mileage update"
  )
end

# For car1_customer2
unless MileageRecord.exists?(car_id: car1_customer2.id, mileage: 45000)
  MileageRecord.create!(
    car_id: car1_customer2.id,
    mileage: 45000,
    recorded_at: 2.years.ago,
    notes: "Initial mileage record"
  )
end

unless MileageRecord.exists?(car_id: car1_customer2.id, mileage: 65000)
  MileageRecord.create!(
    car_id: car1_customer2.id,
    mileage: 65000,
    recorded_at: 1.year.ago,
    notes: "Technical inspection"
  )
end

unless MileageRecord.exists?(car_id: car1_customer2.id, mileage: 85000)
  MileageRecord.create!(
    car_id: car1_customer2.id,
    mileage: 85000,
    recorded_at: Date.today,
    notes: "Current mileage update"
  )
end

# Create service schedules for cars
puts "Creating service schedules for Tunisian cars..."

# For car1_customer1
ServiceSchedule.find_or_create_by(car_id: car1_customer1.id, service_type: "Visite Technique") do |schedule|
  schedule.mileage_interval = 20000
  schedule.time_interval = 12 # months
end

ServiceSchedule.find_or_create_by(car_id: car1_customer1.id, service_type: "Renouvellement de Vignette") do |schedule|
  schedule.time_interval = 12 # months
end

# For car1_customer2
ServiceSchedule.find_or_create_by(car_id: car1_customer2.id, service_type: "Visite Technique") do |schedule|
  schedule.mileage_interval = 20000
  schedule.time_interval = 12 # months
end

ServiceSchedule.find_or_create_by(car_id: car1_customer2.id, service_type: "Renouvellement d'Assurance") do |schedule|
  schedule.time_interval = 12 # months
end

# Create appointments
puts "Creating appointments for Tunisian customers..."

# Past appointment for car1_customer1 (only if it doesn't exist)
past_date = 2.months.ago.to_date
past_appointment = Appointment.where(customer_id: tunisian_customer1.id, car_id: car1_customer1.id, date: past_date).first_or_create do |appointment|
  appointment.time = "10:00"
  appointment.status = "completed"
  appointment.notes = "Visite technique complété"
end

# Add service if not already added
unless past_appointment.services.include?(visite_technique)
  past_appointment.services << visite_technique
end

# Upcoming appointment for car1_customer2 (only if it doesn't exist)
future_date = 2.weeks.from_now.to_date
upcoming_appointment = Appointment.where(customer_id: tunisian_customer2.id, car_id: car1_customer2.id, date: future_date).first_or_create do |appointment|
  appointment.time = "14:30"
  appointment.status = "scheduled"
  appointment.notes = "Visite technique requise par la loi"
end

# Add services if not already added
unless upcoming_appointment.services.include?(visite_technique)
  upcoming_appointment.services << visite_technique
end

unless upcoming_appointment.services.include?(vignette_renewal)
  upcoming_appointment.services << vignette_renewal
end

puts "Tunisian market data seeding completed successfully!" 