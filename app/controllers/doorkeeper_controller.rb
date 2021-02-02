class DoorkeeperController < ActionController::API
  def user
    user = User.find_by(email: user_params[:email])
    user&.authenticate(user_params[:password]) || head(:unauthorized)
  end

private
  def user_params
    {}.tap do |h|
      h[:email] = params.require(:email)
      h[:password] = params.require(:password)
    end
  end
end