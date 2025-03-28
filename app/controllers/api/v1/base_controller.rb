module Api
  module V1
    class BaseController < ApplicationController
      include Pundit::Authorization
      
      before_action :authenticate_request
      before_action :set_locale
      
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      
      attr_reader :current_user
      
      protected
      
      def authenticate_request
        token = request.headers["Authorization"]
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
    end
  end
end 