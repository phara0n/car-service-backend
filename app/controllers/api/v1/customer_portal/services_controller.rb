module Api
  module V1
    module CustomerPortal
      class ServicesController < Api::V1::BaseController
        before_action :ensure_customer
        before_action :set_service, only: [:show]
        
        # GET /api/v1/customer_portal/services
        def index
          @services = Service.where(active: true).order(name: :asc)
          render json: @services
        end
        
        # GET /api/v1/customer_portal/services/:id
        def show
          render json: @service
        end
        
        private
        
        def ensure_customer
          unless current_user.customer
            render json: { error: 'Not a customer account' }, status: :forbidden
          end
        end
        
        def set_service
          @service = Service.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Service not found' }, status: :not_found
        end
      end
    end
  end
end 