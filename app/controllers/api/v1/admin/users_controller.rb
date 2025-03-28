module Api
  module V1
    module Admin
      class UsersController < Api::V1::BaseController
        before_action :set_user, only: [:show, :update, :destroy]
        
        def index
          @users = policy_scope(User).page(params[:page] || 1).per(params[:per_page] || 25)
          authorize User
          
          render json: @users, each_serializer: UserSerializer, 
                 meta: { total: @users.total_count, page: @users.current_page, per_page: @users.limit_value }
        end
        
        def show
          authorize @user
          
          render json: @user
        end
        
        def create
          @user = User.new(user_params)
          authorize @user
          
          if @user.save
            render json: @user, status: :created
          else
            render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        def update
          authorize @user
          
          if @user.update(user_params)
            render json: @user
          else
            render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        def destroy
          authorize @user
          
          if @user.destroy
            head :no_content
          else
            render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        private
        
        def set_user
          @user = User.find(params[:id])
        end
        
        def user_params
          # Strong parameters
          permitted = [:name, :email, :password, :password_confirmation, :role]
          
          # Only superadmins can set the superadmin flag
          permitted << :is_superadmin if current_user.superadmin?
          
          params.require(:user).permit(permitted)
        end
      end
    end
  end
end 