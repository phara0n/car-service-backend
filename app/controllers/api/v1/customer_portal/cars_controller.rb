module Api
  module V1
    module CustomerPortal
      class CarsController < Api::V1::BaseController
        before_action :ensure_customer
        before_action :set_car, only: [:show, :update_mileage]
        before_action :authorize_car, only: [:show, :update_mileage]
        
        # GET /api/v1/customer_portal/cars
        def index
          @cars = Car.where(customer_id: current_user.customer.id).order(created_at: :desc)
          render json: @cars
        end
        
        # GET /api/v1/customer_portal/cars/:id
        def show
          render json: @car
        end
        
        # PATCH /api/v1/customer_portal/cars/:id/update_mileage
        def update_mileage
          if params[:current_mileage].present?
            # Create a new mileage record
            mileage_record = @car.mileage_records.new(
              mileage: params[:current_mileage],
              recorded_at: Time.current,
              notes: "Updated by customer through portal"
            )
            
            if mileage_record.save
              # Update the car's current mileage
              @car.update(current_mileage: params[:current_mileage])
              
              # Update service predictions for this car
              ServicePredictionService.update_predictions_for_car(@car)
              
              render json: @car
            else
              render json: { errors: mileage_record.errors.full_messages }, status: :unprocessable_entity
            end
          else
            render json: { error: 'Current mileage is required' }, status: :unprocessable_entity
          end
        end
        
        private
        
        def ensure_customer
          unless current_user.customer
            render json: { error: 'Not a customer account' }, status: :forbidden
          end
        end
        
        def set_car
          @car = Car.find(params[:id])
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