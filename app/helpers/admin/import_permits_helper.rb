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

  def special_select(campagne,active)
    #se non ci sono campagne
    if campagne.blank? && active.blank?
      select_tag :campagna,"<option value = '' selected>-Seleziona-</option>"
    else
      #se ci sono campagne ma non c'è una campagna attiva, ma solo non attive
      if active.blank?
        select_tag :campagna,"<option value = '' selected>-Seleziona-</option>" + "<optgroup label='Non attive'>" + options_from_collection_for_select(campagne,:id,:descrizione) + "</optgroup>"
      #se ci sono campagne ma non non attive, ma solo quella attiva
      elsif !active.blank? && campagne.blank?
        group_op = [['Attiva',[["#{active.descrizione}","#{active.id}"]]] ]
        select_tag :campagna,"<option value = '' selected>-Seleziona-</option>" + grouped_options_for_select(group_op)
      #se ci sono campagne, sia quella attiva che quelle non attive
      else
        group_op = [['Attiva',[["#{active.descrizione}","#{active.id}"]]] ]
        select_tag :campagna,"<option value = '' selected>-Seleziona-</option>" + grouped_options_for_select(group_op) + "<optgroup label='Non attive'>" + options_from_collection_for_select(campagne,:id,:descrizione) + "</optgroup>"
      end
    end
  end

end
