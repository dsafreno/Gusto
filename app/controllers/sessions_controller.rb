class SessionsController < ApplicationController
  def create
    user = User.find_by_username(params[:session][:username])
    current_user = user if user && user.password == params[:session][:password]
    if current_user
      session[:user_id] = current_user.id
      redirect_to "/pins"
    else
      flash[:error] = "Error signing in: username or password invalid."
      redirect_to "/signin"
    end
  end
  def destroy
    reset_session
    redirect_to :root
  end
end
