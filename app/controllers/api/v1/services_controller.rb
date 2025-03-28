module Api
  module V1
    class ServicesController < BaseController
      before_action :set_service, only: [:show, :update, :destroy]
      before_action :authorize_admin_action, only: [:create, :update, :destroy]
      
      # GET /api/v1/services
      def index
        @services = Service.order(created_at: :desc)
        render json: @services
      end
      
      # GET /api/v1/services/:id
      def show
        render json: @service
      end
      
      # POST /api/v1/services
      def create
        @service = Service.new(service_params)
        
        if @service.save
          render json: @service, status: :created
        else
          render json: { errors: @service.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # PUT/PATCH /api/v1/services/:id
      def update
        if @service.update(service_params)
          render json: @service
        else
          render json: { errors: @service.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/services/:id
      def destroy
        @service.destroy
        head :no_content
      end
      
      private
      
      def set_service
        @service = Service.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Service not found' }, status: :not_found
      end
      
      def authorize_admin_action
        unless current_user.superadmin? || current_user.admin?
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end
      
      def service_params
        params.require(:service).permit(:name, :description, :price, :duration, :active)
      end
    end
  end
end 