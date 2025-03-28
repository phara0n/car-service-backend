# Service Prediction System

## Overview

The Service Prediction System is an advanced feature of the Car Service Management application that helps both administrators and customers plan for upcoming vehicle maintenance. The system analyzes historical mileage data to predict when vehicles will need service, allowing for proactive maintenance scheduling.

## How It Works

### Core Algorithm

The prediction system works through the following process:

1. **Average Daily Mileage Calculation**:
   - Analyzes historical mileage records for each vehicle
   - Calculates the average daily mileage usage based on timestamp differences
   - More records lead to more accurate predictions

2. **Next Service Prediction**:
   - Combines the average daily mileage with service schedule requirements
   - Calculates remaining mileage until the next service threshold
   - Determines the estimated date when the vehicle will reach the service threshold

3. **Automatic Updates**:
   - Predictions are automatically recalculated whenever:
     - New mileage records are added
     - Existing mileage records are updated
     - Service schedules are modified

4. **Due Soon Detection**:
   - Identifies vehicles due for service within customizable thresholds
   - Default settings flag services due within 500 miles or 7 days
   - Provides an early warning system for both administrators and customers

## Key Components

### Service Prediction Service

The `ServicePredictionService` class contains the core logic for predictions:

```ruby
def self.predict_next_service_date(car, service_schedule)
  # Calculate average daily mileage based on records
  avg_daily_mileage = calculate_average_daily_mileage(car)
  
  # Calculate how much mileage is left until the next service
  mileage_to_go = service_schedule.next_service_mileage - car.current_mileage
  
  # Calculate days until next service based on average daily mileage
  days_to_go = (mileage_to_go / avg_daily_mileage).ceil
  
  # Return the predicted date
  Date.today + days_to_go.days
end
```

### Database Structure

The system relies on the following key database fields:

1. **In the Car model**:
   - `current_mileage`: The most recent recorded mileage
   - `average_daily_mileage`: Calculated average daily mileage

2. **In the ServiceSchedule model**:
   - `mileage_interval`: How often service is needed by mileage
   - `time_interval_days`: How often service is needed by time
   - `last_service_mileage`: Mileage at last service
   - `last_service_date`: Date of last service
   - `predicted_next_service_date`: Calculated next date for service

3. **In the MileageRecord model**:
   - `mileage`: The recorded mileage value
   - `recorded_at`: When the mileage was recorded
   - `car_id`: The associated car

## Administrator Features

Administrators have access to specialized tools for service prediction:

1. **Due Soon Dashboard**:
   - API endpoint: `GET /api/v1/service_predictions/due_soon`
   - Lists all vehicles due for service soon across all customers
   - Includes customer contact information for proactive outreach
   - Supports efficient service scheduling and workforce planning

2. **Individual Car Predictions**:
   - API endpoint: `GET /api/v1/service_predictions/cars/:car_id`
   - Detailed view of service predictions for any car
   - Helps administrators provide accurate service planning advice

3. **Manual Prediction Updates**:
   - API endpoint: `POST /api/v1/service_predictions/cars/:car_id/update`
   - Force recalculation of predictions when needed

## Customer Features

Customers have access to their own prediction information:

1. **All Cars Overview**:
   - API endpoint: `GET /api/v1/customer_portal/service_predictions`
   - Summarizes prediction data for all customer-owned vehicles
   - Presents a comprehensive view of maintenance needs

2. **Individual Car Details**:
   - API endpoint: `GET /api/v1/customer_portal/service_predictions/cars/:car_id`
   - Detailed prediction information for a specific vehicle
   - Shows upcoming service schedules with estimated dates and mileage

3. **Mileage Updates**:
   - API endpoint: `PATCH /api/v1/customer_portal/cars/:id/update_mileage`
   - Allows customers to update their current mileage
   - Automatically recalculates predictions based on new data

## Benefits

1. **For Service Centers**:
   - Improved scheduling and resource allocation
   - Proactive customer communication
   - Increased customer retention through timely service reminders
   - Better inventory management for parts and supplies

2. **For Vehicle Owners**:
   - Advanced notice of upcoming maintenance needs
   - Better financial planning for service expenses
   - Reduced risk of breakdowns from missed maintenance
   - Convenient service scheduling based on predictions

## Technical Implementation Considerations

1. **Performance Optimization**:
   - Prediction calculations are performed on-demand
   - Results are stored in the database to avoid redundant calculations
   - Bulk updates trigger recalculation for affected vehicles only

2. **Accuracy Improvement**:
   - The system becomes more accurate as more mileage data is collected
   - Outliers in mileage patterns can be manually adjusted
   - Service intervals can be customized per vehicle if needed

3. **Error Handling**:
   - Graceful handling of insufficient data (less than 2 mileage records)
   - Protection against division by zero in time calculations
   - Clear indication when predictions cannot be made

## Future Enhancements

1. **Machine Learning Integration**:
   - Incorporate seasonal driving patterns
   - Account for individual driving habits
   - Predict service needs based on similar vehicles

2. **Push Notifications**:
   - SMS/Email alerts for upcoming service needs
   - Mobile app notifications

3. **Appointment Integration**:
   - One-click scheduling from prediction alerts
   - Automated appointment suggestions

4. **Multi-factor Prediction**:
   - Consider weather and driving conditions
   - Account for vehicle age and condition
   - Factor in manufacturer service bulletins 