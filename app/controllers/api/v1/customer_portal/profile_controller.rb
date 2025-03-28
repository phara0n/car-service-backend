module Api
  module V1
    module CustomerPortal
      class ProfileController < Api::V1::BaseController
        before_action :ensure_customer
        
        # GET /api/v1/customer_portal/profile
        def show
          render json: current_user.customer
        end
        
        # PUT/PATCH /api/v1/customer_portal/profile
        def update
          if current_user.customer.update(customer_params)
            render json: current_user.customer
          else
            render json: { errors: current_user.customer.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        private
        
        def ensure_customer
          unless current_user.customer
            render json: { error: 'Not a customer account' }, status: :forbidden
          end
        end
        
        def customer_params
          params.require(:customer).permit(:name, :email, :phone, :address, :region_code)
        end
      end
    end
  end
end 