module Api
  module V1
    module CustomerPortal
      class AppointmentsController < Api::V1::BaseController
        before_action :ensure_customer
        before_action :set_appointment, only: [:show]
        before_action :authorize_appointment, only: [:show]
        
        # GET /api/v1/customer_portal/appointments
        def index
          @appointments = Appointment.includes(:car, :services)
                           .where(customer_id: current_user.customer.id)
                           .order(date: :desc, time: :asc)
          render json: @appointments
        end
        
        # GET /api/v1/customer_portal/appointments/:id
        def show
          render json: @appointment
        end
        
        # POST /api/v1/customer_portal/appointments
        def create
          # Make sure customer can only create appointments for their own cars
          car = Car.find_by(id: appointment_params[:car_id], customer_id: current_user.customer.id)
          
          unless car
            return render json: { error: 'Car not found or not owned by customer' }, status: :not_found
          end
          
          # Force customer_id to be the current customer's id
          @appointment = Appointment.new(appointment_params.merge(customer_id: current_user.customer.id))
          
          # Process service_ids if present
          if params[:appointment][:service_ids].present?
            @appointment.services = Service.where(id: params[:appointment][:service_ids])
          end
          
          # Set status to pending by default
          @appointment.status = 'pending' unless @appointment.status.present?
          
          if @appointment.save
            render json: @appointment, status: :created
          else
            render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        private
        
        def ensure_customer
          unless current_user.customer
            render json: { error: 'Not a customer account' }, status: :forbidden
          end
        end
        
        def set_appointment
          @appointment = Appointment.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Appointment not found' }, status: :not_found
        end
        
        def authorize_appointment
          unless @appointment.customer_id == current_user.customer.id
            render json: { error: 'Unauthorized' }, status: :unauthorized
          end
        end
        
        def appointment_params
          params.require(:appointment).permit(
            :car_id, :date, :time, :notes
          )
        end
      end
    end
  end
end 