class AuthenticationService
  attr_reader :email, :password, :user, :errors

  def initialize(email, password)
    @email = email
    @password = password
    @errors = []
  end

  def authenticate
    @user = User.find_by(email: email.downcase)

    if user&.authenticate(password)
      create_token
    else
      @errors << 'Invalid email or password'
      nil
    end
  end

  def create_token
    payload = {
      user_id: user.id,
      email: user.email,
      role: user.role,
      is_superadmin: user.is_superadmin,
      exp: 24.hours.from_now.to_i
    }
    JsonWebToken.encode(payload)
  end

  def self.authenticate_token(token)
    return nil if token.blank?

    # Remove "Bearer " from token if present
    token = token.gsub(/^Bearer /, '') if token.start_with?('Bearer ')

    payload = JsonWebToken.decode(token)
    return nil unless payload

    User.find_by(id: payload[:user_id])
  rescue ActiveRecord::RecordNotFound
    nil
  end
end 