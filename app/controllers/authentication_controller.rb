class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request
  skip_before_action :verify_authenticity_token

  def login
    @user = User.find_by(email: params[:email])
    password = BCrypt::Password.new(@user.password_digest)
    if password == params[:password]
      token = JsonWebToken.encode(user_id: @user.id)
      time = Time.current + 24.hours.to_i
      json_success('Signed in successfully.', token: token, expires_at: time.strftime('%m-%d-%Y %H:%M'))
    else
      failed_auth_response
    end
  end

  private

  def check_user_exist
    failed_auth_response unless User.find_by(email: params[:email])
  end

  def failed_auth_response
    json_not_found('Could not authenticate. Please check your credentials and try again.')
  end

  def required_params
    json_bad_request('Email and password are required fields.') if params[:email].blank? || params[:password].blank?
  end
end
