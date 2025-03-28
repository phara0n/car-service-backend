module Api
  module V1
    class AppointmentsController < BaseController
      before_action :set_appointment, only: [:show, :update, :destroy]
      before_action :authorize_appointment, only: [:show, :update, :destroy]
      
      # GET /api/v1/appointments
      def index
        if current_user.superadmin? || current_user.admin?
          @appointments = Appointment.includes(:customer, :car, :services).order(date: :desc, time: :asc)
        else
          # Customer can only see their own appointments
          @appointments = Appointment.includes(:customer, :car, :services)
                           .where(customer_id: current_user.customer.id)
                           .order(date: :desc, time: :asc)
        end
        
        render json: @appointments
      end
      
      # GET /api/v1/appointments/:id
      def show
        render json: @appointment
      end
      
      # POST /api/v1/appointments
      def create
        @appointment = Appointment.new(appointment_params)
        
        # Process service_ids if present
        if params[:appointment][:service_ids].present?
          @appointment.services = Service.where(id: params[:appointment][:service_ids])
        end
        
        if @appointment.save
          render json: @appointment, status: :created
        else
          render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # PUT/PATCH /api/v1/appointments/:id
      def update
        # Process service_ids if present
        if params[:appointment][:service_ids].present?
          @appointment.services = Service.where(id: params[:appointment][:service_ids])
        end
        
        if @appointment.update(appointment_params)
          render json: @appointment
        else
          render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/appointments/:id
      def destroy
        @appointment.destroy
        head :no_content
      end
      
      private
      
      def set_appointment
        @appointment = Appointment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Appointment not found' }, status: :not_found
      end
      
      def authorize_appointment
        unless current_user.superadmin? || current_user.admin? || 
               (current_user.customer && current_user.customer.id == @appointment.customer_id)
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end
      
      def appointment_params
        params.require(:appointment).permit(
          :customer_id, :car_id, :date, :time, :status, :notes
        )
      end
    end
  end
end 