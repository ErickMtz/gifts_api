class SessionsController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def new
    @info = ''
    session[:return_to] = params[:return_to]
    session[:client_id] = params[:client_id]
  end

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path
    else
      @info = 'Email or password is invalid'
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  def current
  end

private
  helper_method :current_user
  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      @current_user = nil
    end
  end
end
