module Admin::ImportPermitsHelper
  def admin_red_green(td_element)
    if td_element.name.blank?
      content_tag(:td,"", :class => "red")
    else
      content_tag :td, :class => "green" do
        concat(link_to td_element.name, download_ss_path(td_element.id))
        if td_element.import_permit == false
          concat("<br />")
          concat(button_to_remote "Elimina Scheda",:url=>{:controller => "admin/import_permits",:action => "delete_file", :file_id => td_element.id}, :confirm => "Eliminando la scheda richiederai un nuovo caricamento della stessa al rilevatore. Continuare?")
          concat(button_to_remote "Assegna Permesso",:url=>{:controller => "admin/import_permits",:action => "create_permit", :file_id => td_element.id})
        elsif td_element.import_permit == true
          concat("<br />")
          concat( button_to_remote "Revoca Permesso",:url=>{:controller => "admin/import_permits",:action => "delete_permit", :file_id => td_element.id})
        end
      end
    end
  end
end
