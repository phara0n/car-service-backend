module Api
  module V1
    class ServicePredictionsController < BaseController
      before_action :authorize_admin, only: [:service_due_soon, :update_predictions]
      before_action :set_car, only: [:car_predictions, :update_predictions]
      
      # GET /api/v1/service_predictions/due_soon
      # Get a list of all cars due for service soon
      def service_due_soon
        # Get all cars
        cars = Car.includes(:customer, :service_schedules)
        
        # Filter to only cars with services due soon
        due_soon_cars = cars.select do |car|
          ServicePredictionService.due_for_service_soon?(car)
        end
        
        # Format the response
        @response = due_soon_cars.map do |car|
          {
            car: {
              id: car.id,
              make: car.make,
              model: car.model,
              year: car.year,
              license_plate: car.license_plate,
              current_mileage: car.current_mileage
            },
            customer: {
              id: car.customer.id,
              name: car.customer.name,
              email: car.customer.email,
              phone: car.customer.phone
            },
            services_due: ServicePredictionService.services_due_soon(car).map do |schedule|
              {
                id: schedule.id,
                service_type: schedule.service_type,
                next_service_mileage: schedule.next_service_mileage,
                next_service_date: schedule.next_service_date,
                predicted_next_service_date: schedule.predicted_next_service_date,
                mileage_to_go: schedule.next_service_mileage - car.current_mileage,
                days_to_go: (schedule.next_service_date - Date.today).to_i
              }
            end
          }
        end
        
        render json: @response
      end
      
      # GET /api/v1/service_predictions/cars/:car_id
      # Get predictions for a specific car
      def car_predictions
        # Ensure either admin or the car's owner
        unless current_user.admin? || current_user.superadmin? || 
               (current_user.customer && @car.customer_id == current_user.customer.id)
          return render json: { error: 'Unauthorized' }, status: :unauthorized
        end
        
        # Update predictions
        ServicePredictionService.update_predictions_for_car(@car)
        
        # Format the response
        @response = {
          car: {
            id: @car.id,
            make: @car.make,
            model: @car.model,
            year: @car.year,
            license_plate: @car.license_plate,
            current_mileage: @car.current_mileage,
            average_daily_mileage: @car.average_daily_mileage
          },
          service_schedules: @car.service_schedules.map do |schedule|
            {
              id: schedule.id,
              service_type: schedule.service_type,
              next_service_mileage: schedule.next_service_mileage,
              next_service_date: schedule.next_service_date,
              predicted_next_service_date: schedule.predicted_next_service_date,
              mileage_to_go: schedule.next_service_mileage - @car.current_mileage,
              days_to_go: (schedule.next_service_date - Date.today).to_i
            }
          end
        }
        
        render json: @response
      end
      
      # POST /api/v1/service_predictions/cars/:car_id/update
      # Manually trigger an update of service predictions for a car
      def update_predictions
        ServicePredictionService.update_predictions_for_car(@car)
        
        render json: { message: "Predictions updated for #{@car.make} #{@car.model}" }
      end
      
      private
      
      def set_car
        @car = Car.find(params[:car_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Car not found' }, status: :not_found
      end
      
      def authorize_admin
        unless current_user.admin? || current_user.superadmin?
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end
    end
  end
end 