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
        # Check if a customer with the same email or phone already exists
        existing_customer_by_email = Customer.find_by(email: params[:customer][:email])
        existing_customer_by_phone = Customer.find_by(phone: params[:customer][:phone])
        
        if existing_customer_by_email
          render json: { errors: ["A customer with email #{params[:customer][:email]} already exists"] }, status: :unprocessable_entity
          return
        end
        
        if existing_customer_by_phone
          render json: { errors: ["A customer with phone #{params[:customer][:phone]} already exists"] }, status: :unprocessable_entity
          return
        end
        
        # Check if a user with the email already exists
        existing_user = User.find_by(email: params[:customer][:email])
        
        # Check if the existing user is already associated with a customer
        if existing_user && existing_user.customer.present?
          render json: { errors: ["A user with email #{params[:customer][:email]} is already associated with another customer"] }, status: :unprocessable_entity
          return
        end
        
        @customer = Customer.new(customer_params)
        
        # If creating a customer from an admin, we need to create a user account
        if params[:customer][:user_attributes].blank?
          if existing_user
            # When using an existing user, we don't need to validate password
            @customer.user = existing_user
          else
            # Generate matching password and confirmation for new users
            password = SecureRandom.hex(8)
            @customer.build_user(
              email: params[:customer][:email],
              name: params[:customer][:name],
              role: 'customer',
              password: password,
              password_confirmation: password
            )
          end
        end
        
        authorize @customer
        
        if @customer.save
          render json: @customer, status: :created
        else
          # Get more detailed error information
          user_errors = @customer.user&.errors&.full_messages || []
          customer_errors = @customer.errors.full_messages
          all_errors = customer_errors + user_errors
          
          # Log errors for debugging
          Rails.logger.error("Failed to create customer: #{all_errors.join(', ')}")
          
          render json: { errors: all_errors }, status: :unprocessable_entity
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
      
      # Get all cars for a specific customer
      def cars
        begin
          @customer = Customer.find(params[:customer_id])
          authorize @customer
          
          @cars = @customer.cars
          
          render json: @cars
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Customer not found" }, status: :not_found
        rescue Pundit::NotAuthorizedError
          render json: { error: "You are not authorized to view this customer's cars" }, status: :forbidden
        rescue => e
          # Log the error for debugging
          Rails.logger.error("Error in customers#cars: #{e.message}")
          Rails.logger.error(e.backtrace.join("\n"))
          
          render json: { error: "An error occurred while fetching cars: #{e.message}" }, status: :internal_server_error
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