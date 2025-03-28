module Api
  module V1
    class CustomersController < BaseController
      before_action :set_customer, only: [:show, :update, :destroy]
      
      def index
        @customers = policy_scope(Customer).page(params[:page] || 1).per(params[:per_page] || 25)
        authorize Customer
        
        render json: @customers, each_serializer: CustomerSerializer, 
               meta: { total: @customers.total_count, page: @customers.current_page, per_page: @customers.limit_value }
      end
      
      def show
        authorize @customer
        
        render json: @customer
      end
      
      def create
        @customer = Customer.new(customer_params)
        # If creating a customer from an admin, we need to create a user account
        if params[:customer][:user_attributes].blank?
          @customer.build_user(
            email: params[:customer][:email],
            name: params[:customer][:name],
            role: 'customer',
            password: SecureRandom.hex(8),  # Generate random password
            password_confirmation: ''
          )
        end
        
        authorize @customer
        
        if @customer.save
          # Send welcome email with credentials if a new user was created
          # CustomerMailer.welcome_email(@customer).deliver_later
          
          render json: @customer, status: :created
        else
          render json: { errors: @customer.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def update
        authorize @customer
        
        if @customer.update(customer_params)
          render json: @customer
        else
          render json: { errors: @customer.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def destroy
        authorize @customer
        
        if @customer.destroy
          head :no_content
        else
          render json: { errors: @customer.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      private
      
      def set_customer
        @customer = Customer.find(params[:id])
      end
      
      def customer_params
        params.require(:customer).permit(
          :name, :email, :phone, :address, :national_id, :tax_number, :region_code,
          user_attributes: [:id, :email, :name, :password, :password_confirmation]
        )
      end
    end
  end
end 