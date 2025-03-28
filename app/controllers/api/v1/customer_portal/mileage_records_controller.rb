module Api
  module V1
    module CustomerPortal
      class MileageRecordsController < Api::V1::BaseController
        before_action :ensure_customer
        
        # GET /api/v1/customer_portal/mileage_records
        def index
          @mileage_records = MileageRecord.includes(:car)
                              .joins(car: :customer)
                              .where(cars: { customer_id: current_user.customer.id })
                              .order(created_at: :desc)
          render json: @mileage_records
        end
        
        # POST /api/v1/customer_portal/mileage_records
        def create
          # Ensure the car belongs to the current customer
          car = Car.find_by(id: mileage_record_params[:car_id], customer_id: current_user.customer.id)
          
          unless car
            return render json: { error: 'Car not found or not owned by customer' }, status: :not_found
          end
          
          @mileage_record = MileageRecord.new(mileage_record_params)
          
          # Set recorded_at if not provided
          @mileage_record.recorded_at = Time.current unless @mileage_record.recorded_at
          
          if @mileage_record.save
            # Update the car's current mileage
            car.update(current_mileage: @mileage_record.mileage)
            
            # Update service predictions for this car
            ServicePredictionService.update_predictions_for_car(car)
            
            render json: @mileage_record, status: :created
          else
            render json: { errors: @mileage_record.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        private
        
        def ensure_customer
          unless current_user.customer
            render json: { error: 'Not a customer account' }, status: :forbidden
          end
        end
        
        def mileage_record_params
          params.require(:mileage_record).permit(:car_id, :mileage, :notes, :recorded_at)
        end
      end
    end
  end
end 