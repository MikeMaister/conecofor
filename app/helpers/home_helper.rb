module HomeHelper

  def download_manuale
    if current_user.user_kind.kind == "Admin"
      link_to "Manuale Admin", download_admin_manual_path
    elsif current_user.user_kind.kind == "Rilevatore"
      link_to "Manuale Rilevatore", download_rilevatore_manual_path
    end
  end

end
