class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params[:login], params[:password])
    if user
      #resetto la sessione precedente
      reset_session
      #genero il remember_token
      user.generate_remember_token

      #se è stato spuntato il remember me
      if params[:remember_me]
        #creo il cookie e lo rendo permanente (finche non lo cancello con il logout)
        cookies.permanent[:rem_token] = user.remember_token
      #altrimenti
      else
        #creo il cookie che si distrugge a fine sessione
        cookies[:rem_token] = user.remember_token
      end

      flash[:notice] = "Logged in successfully."
      #redirect_to_target_or_default(root_url)
      redirect_to root_path
    else
      flash[:error] = "Invalid login or password."
      redirect_to :controller => "home"
    end
  end

  def destroy
    cookies.delete :rem_token
    flash[:notice] = "You have been logged out."
    redirect_to root_url
  end

  private

  #resetta le variabili di sessione
  def reset_session
    cookies.delete :rem_token
  end
end
