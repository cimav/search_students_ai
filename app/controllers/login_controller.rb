class LoginController < ApplicationController

  layout "login"

  def index
    redirect_to root_path if session[:user_id].present?
  end
end
