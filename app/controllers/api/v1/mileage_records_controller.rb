module Api
  module V1
    class MileageRecordsController < BaseController
      before_action :set_mileage_record, only: [:show, :update, :destroy]
      before_action :authorize_mileage_record, only: [:show, :update, :destroy]
      
      # GET /api/v1/mileage_records
      def index
        if current_user.superadmin? || current_user.admin?
          @mileage_records = MileageRecord.includes(:car).order(created_at: :desc)
        else
          # Customer can only see their own mileage records
          @mileage_records = MileageRecord.includes(:car)
                              .joins(car: :customer)
                              .where(cars: { customer_id: current_user.customer.id })
                              .order(created_at: :desc)
        end
        
        render json: @mileage_records
      end
      
      # GET /api/v1/mileage_records/:id
      def show
        render json: @mileage_record
      end
      
      # POST /api/v1/mileage_records
      def create
        @mileage_record = MileageRecord.new(mileage_record_params)
        
        # Ensure recorded_at is set if not provided
        unless @mileage_record.recorded_at
          @mileage_record.recorded_at = Time.current
        end
        
        # If customer adding record, make sure it's for their car
        if !current_user.admin? && !current_user.superadmin?
          car = Car.find_by(id: @mileage_record.car_id, customer_id: current_user.customer.id)
          unless car
            return render json: { error: 'Unauthorized' }, status: :unauthorized
          end
        end
        
        if @mileage_record.save
          # Update the car's current mileage
          car = @mileage_record.car
          car.update(current_mileage: @mileage_record.mileage)
          
          # Update service predictions for this car
          ServicePredictionService.update_predictions_for_car(car)
          
          render json: @mileage_record, status: :created
        else
          render json: { errors: @mileage_record.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # PUT/PATCH /api/v1/mileage_records/:id
      def update
        if @mileage_record.update(mileage_record_params)
          # Update the car's current mileage if this is the latest record
          if @mileage_record.car.mileage_records.order(recorded_at: :desc).first.id == @mileage_record.id
            @mileage_record.car.update(current_mileage: @mileage_record.mileage)
            
            # Update service predictions for this car
            ServicePredictionService.update_predictions_for_car(@mileage_record.car)
          end
          
          render json: @mileage_record
        else
          render json: { errors: @mileage_record.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/mileage_records/:id
      def destroy
        car = @mileage_record.car
        @mileage_record.destroy
        
        # Re-calculate the current mileage from the latest remaining record
        latest_record = car.mileage_records.first
        if latest_record
          car.update(current_mileage: latest_record.mileage)
          
          # Update service predictions for this car
          ServicePredictionService.update_predictions_for_car(car)
        end
        
        head :no_content
      end
      
      private
      
      def set_mileage_record
        @mileage_record = MileageRecord.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Mileage record not found' }, status: :not_found
      end
      
      def authorize_mileage_record
        unless current_user.superadmin? || current_user.admin? || 
               (current_user.customer && 
                @mileage_record.car.customer_id == current_user.customer.id)
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end
      
      def mileage_record_params
        params.require(:mileage_record).permit(:car_id, :mileage, :notes, :recorded_at)
      end
    end
  end
end 