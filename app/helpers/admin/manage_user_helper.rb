module Admin::ManageUserHelper
  def active_deactive(user)
    if user.approved
      button_to "Disattiva", :controller => "admin/manage_user", :action => "deactivate", :user => user.id
    else
      button_to "Attiva", :controller => "admin/manage_user", :action => "activate", :user => user.id
    end
  end
end
