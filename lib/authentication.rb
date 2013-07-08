# This module is included in your application controller which makes
# several methods available to all controllers and views. Here's a
# common example you might add to your application layout file.
#
#   <% if logged_in? %>
#     Welcome <%=h current_user.username %>! Not you?
#     <%= link_to "Log out", logout_path %>
#   <% else %>
#     <%= link_to "Sign up", signup_path %> or
#     <%= link_to "log in", login_path %>.
#   <% end %>
#
# You can also restrict unregistered users from accessing a controller using
# a before filter. For example.
#
#   before_filter :login_required, :except => [:index, :show]
module Authentication
  def self.included(controller)
    controller.send :helper_method, :current_user, :logged_in?, :redirect_to_target_or_default
    controller.filter_parameter_logging :password
  end

  def current_user
    #@current_user ||= User.find(session[:user_id]) if session[:user_id]
    @current_user ||= User.find_by_remember_token(cookies[:rem_token]) if cookies[:rem_token]
  end

  def logged_in?
    current_user
  end

  def login_required
    unless logged_in?
      flash[:error] = "Deve essere un utente registrato e loggato per poter accedere alla pagina richiesta."
      store_target_location
      redirect_to root_url
    end
  end

  def logout_required
    unless logged_in?.blank?
      flash[:error] = "Deve effettuare il logout per poter accedere alla pagina richiesta."
      store_target_location
      redirect_to root_url
    end
  end

  def rilevatore_approvato
    unless (current_user.user_kind_id == UserKind.find_by_kind("Rilevatore").identifier) && (User.find(:first, :conditions => ["id = ? AND approved = true", current_user.id]))
      flash[:error] = "La sua richiesta di registrazione non è stata ancora approvata."
      redirect_to root_url
    end
  end

  def rilevatore_authorization_required
    if current_user.user_kind_id != UserKind.find_by_kind("Rilevatore").identifier
      flash[:error] = "You don't have the authorization to access the requested page."
      redirect_to root_url
    end
  end

  def admin_authorization_required
    unless (current_user.user_kind_id == UserKind.find_by_kind("Admin").identifier)
      flash[:error] = "You don't have the authorization to access the requested page."
      redirect_to :controller => "home" , :action => "index"
    end
  end

  def redirect_to_target_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  private

  def store_target_location
    session[:return_to] = request.request_uri
  end
end
