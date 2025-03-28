module Api
  module V1
    class BaseController < ActionController::API
      include ActionController::RequestForgeryProtection
      include Pundit::Authorization
      
      protect_from_forgery with: :null_session
      before_action :authenticate_request
      before_action :set_locale
      
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from StandardError, with: :handle_error
      
      attr_reader :current_user
      
      protected
      
      def authenticate_request
        token = request.headers["Authorization"]&.gsub('Bearer ', '')
        @current_user = AuthenticationService.authenticate_token(token)
        
        render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
      end
      
      def set_locale
        I18n.locale = request.headers["Accept-Language"]&.downcase&.split(',')&.first || I18n.default_locale
      end
      
      private
      
      def user_not_authorized(exception)
        policy_name = exception.policy.class.to_s.underscore
        
        render json: { 
          error: I18n.t("#{policy_name}.#{exception.query}", scope: 'pundit', default: 'You are not authorized to perform this action.') 
        }, status: :forbidden
      end
      
      def not_found
        render json: { error: 'Resource not found' }, status: :not_found
      end

      def handle_error(exception)
        Rails.logger.error "#{exception.class}: #{exception.message}"
        Rails.logger.error exception.backtrace.join("\n")
        
        render json: { error: 'Internal server error' }, status: :internal_server_error
      end
    end
  end
end 