module HomeHelper

  def download_manuale
    if current_user.user_kind.kind == "Admin"
      link_to "Manuale Admin"
    elsif current_user.user_kind.kind == "Rilevatore"
      link_to "Manuale Rilevatore"
    end
  end

end
