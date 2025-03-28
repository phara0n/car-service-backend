module Api
  module V1
    module CustomerPortal
      class ServicePredictionsController < Api::V1::BaseController
        before_action :ensure_customer
        before_action :set_car, only: [:car_predictions]
        before_action :authorize_car, only: [:car_predictions]
        
        # GET /api/v1/customer_portal/service_predictions
        def index
          # Get all cars belonging to the customer
          cars = Car.where(customer_id: current_user.customer.id)
          
          # Collect predictions for all cars
          @predictions = {}
          cars.each do |car|
            @predictions[car.id] = collect_car_predictions(car)
          end
          
          render json: @predictions
        end
        
        # GET /api/v1/customer_portal/service_predictions/cars/:car_id
        def car_predictions
          predictions = collect_car_predictions(@car)
          render json: predictions
        end
        
        private
        
        def collect_car_predictions(car)
          # Update predictions before returning
          ServicePredictionService.update_predictions_for_car(car)
          
          predictions = {
            car_info: {
              id: car.id,
              make: car.make,
              model: car.model,
              year: car.year,
              license_plate: car.license_plate,
              current_mileage: car.current_mileage,
              average_daily_mileage: car.average_daily_mileage
            },
            service_schedules: [],
            services_due_soon: []
          }
          
          # Add all service schedules with predictions
          car.service_schedules.each do |schedule|
            predictions[:service_schedules] << {
              id: schedule.id,
              service_type: schedule.service_type,
              next_service_mileage: schedule.next_service_mileage,
              next_service_date: schedule.next_service_date,
              predicted_next_service_date: schedule.predicted_next_service_date,
              mileage_to_go: schedule.next_service_mileage - car.current_mileage,
              days_to_go: (schedule.next_service_date - Date.today).to_i
            }
          end
          
          # Add services that are due soon
          due_soon = ServicePredictionService.services_due_soon(car)
          due_soon.each do |schedule|
            predictions[:services_due_soon] << {
              id: schedule.id,
              service_type: schedule.service_type,
              next_service_mileage: schedule.next_service_mileage,
              next_service_date: schedule.next_service_date,
              predicted_next_service_date: schedule.predicted_next_service_date,
              mileage_to_go: schedule.next_service_mileage - car.current_mileage,
              days_to_go: (schedule.next_service_date - Date.today).to_i
            }
          end
          
          predictions
        end
        
        def ensure_customer
          unless current_user.customer
            render json: { error: 'Not a customer account' }, status: :forbidden
          end
        end
        
        def set_car
          @car = Car.find(params[:car_id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Car not found' }, status: :not_found
        end
        
        def authorize_car
          unless @car.customer_id == current_user.customer.id
            render json: { error: 'Unauthorized' }, status: :unauthorized
          end
        end
      end
    end
  end
end 