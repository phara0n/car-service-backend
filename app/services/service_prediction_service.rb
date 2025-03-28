class ServicePredictionService
  # Calculate the estimated date for the next service based on
  # historical mileage data and service intervals
  def self.predict_next_service_date(car, service_schedule)
    # If there are no mileage records, can't make prediction
    return nil if car.mileage_records.count < 2
    
    # Calculate average daily mileage based on records
    avg_daily_mileage = calculate_average_daily_mileage(car)
    return nil if avg_daily_mileage.nil? || avg_daily_mileage <= 0
    
    # Calculate how much mileage is left until the next service
    mileage_to_go = service_schedule.next_service_mileage - car.current_mileage
    
    # If mileage is already over the threshold, service is needed now
    return Date.today if mileage_to_go <= 0
    
    # Calculate days until next service based on average daily mileage
    days_to_go = (mileage_to_go / avg_daily_mileage).ceil
    
    # Return the predicted date
    Date.today + days_to_go.days
  end
  
  # Calculate the average daily mileage for a car based on its history
  def self.calculate_average_daily_mileage(car)
    # Need at least two mileage records to calculate a rate
    records = car.mileage_records.order(recorded_at: :asc)
    return 0 if records.count < 2
    
    # Get the first and last record
    first_record = records.first
    last_record = records.last
    
    # Calculate total mileage difference
    mileage_difference = last_record.mileage - first_record.mileage
    
    # Calculate time difference in days
    days_difference = (last_record.recorded_at.to_date - first_record.recorded_at.to_date).to_i
    
    # Avoid division by zero
    return 0 if days_difference == 0
    
    # Calculate the average daily mileage
    (mileage_difference.to_f / days_difference).round(2)
  end
  
  # Update all service predictions for a car
  def self.update_predictions_for_car(car)
    # Calculate and store the average daily mileage
    avg_daily_mileage = calculate_average_daily_mileage(car)
    car.update(average_daily_mileage: avg_daily_mileage)
    
    # Update predictions for each service schedule
    car.service_schedules.each do |schedule|
      predicted_date = predict_next_service_date(car, schedule)
      schedule.update(predicted_next_service_date: predicted_date)
    end
  end
  
  # Check if a car is due for service soon (within the next 7 days or 500 miles)
  def self.due_for_service_soon?(car)
    car.service_schedules.any? do |schedule|
      # Due based on mileage
      (schedule.next_service_mileage - car.current_mileage) <= 500 ||
      # Due based on time interval
      (schedule.next_service_date - Date.today) <= 7
    end
  end
  
  # Get all services that are due soon for a car
  def self.services_due_soon(car)
    car.service_schedules.select do |schedule|
      # Due based on mileage
      (schedule.next_service_mileage - car.current_mileage) <= 500 ||
      # Due based on time interval
      (schedule.next_service_date - Date.today) <= 7
    end
  end
end 