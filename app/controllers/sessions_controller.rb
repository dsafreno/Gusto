class SessionsController < ApplicationController
  def create
    user = User.find_by_email(params[:session][:email])
    current_user = user.authenticate(params[:session][:password]) if user
    if current_user
      session[:user_id] = current_user.id
      redirect_to "/pins"
    else
      flash[:error] = "Error signing in: username or password invalid."
      redirect_to "/signup"
    end
  end
  def destroy
    reset_session
    redirect_to "/signup"
  end
end
