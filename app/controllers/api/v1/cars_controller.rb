module Api
  module V1
    class CarsController < BaseController
      before_action :set_car, only: [:show, :update, :destroy]
      before_action :authorize_car, only: [:show, :update, :destroy]
      
      # GET /api/v1/cars
      def index
        if current_user.superadmin? || current_user.admin?
          @cars = Car.includes(:customer).order(created_at: :desc)
        else
          # Customer can only see their own cars
          @cars = Car.includes(:customer).where(customer_id: current_user.customer.id).order(created_at: :desc)
        end
        
        render json: @cars
      end
      
      # GET /api/v1/cars/:id
      def show
        render json: @car
      end
      
      # POST /api/v1/cars
      def create
        @car = Car.new(car_params)
        
        if @car.save
          render json: @car, status: :created
        else
          render json: { errors: @car.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # PUT/PATCH /api/v1/cars/:id
      def update
        if @car.update(car_params)
          render json: @car
        else
          render json: { errors: @car.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/cars/:id
      def destroy
        @car.destroy
        head :no_content
      end
      
      private
      
      def set_car
        @car = Car.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Car not found' }, status: :not_found
      end
      
      def authorize_car
        unless current_user.superadmin? || current_user.admin? || 
               (current_user.customer && current_user.customer.id == @car.customer_id)
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end
      
      def car_params
        params.require(:car).permit(
          :customer_id, :make, :model, :year, :vin, :license_plate,
          :initial_mileage, :current_mileage, :customs_clearance_number,
          :technical_visit_date, :insurance_category
        )
      end
    end
  end
end 