module Api
  module V1
    class AuthController < ApplicationController
      def login
        # Extract credentials from either direct params or auth wrapper
        email = params[:email] || params.dig(:auth, :email)
        password = params[:password] || params.dig(:auth, :password)
        
        auth_service = AuthenticationService.new(email, password)
        token = auth_service.authenticate
        
        if token
          user = auth_service.user
          render json: {
            token: token,
            user: {
              id: user.id,
              email: user.email,
              name: user.name,
              role: user.role,
              is_superadmin: user.is_superadmin
            }
          }, status: :ok
        else
          render json: { errors: auth_service.errors }, status: :unauthorized
        end
      end
      
      def verify
        token = request.headers["Authorization"]
        user = AuthenticationService.authenticate_token(token)
        
        if user
          render json: {
            user: {
              id: user.id,
              email: user.email,
              name: user.name,
              role: user.role,
              is_superadmin: user.is_superadmin
            }
          }, status: :ok
        else
          render json: { error: 'Invalid token' }, status: :unauthorized
        end
      end
    end
  end
end 