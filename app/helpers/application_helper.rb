# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  #quando il parametro da visualizzare è nullo, mostra il carattere "-"
  def convert_nil(param)
    if param.blank?
      return "-"
    else
      return param
    end
  end

  #setta il focus su un DOM specifico
  def focus_on(id)
    javascript_tag "$('#{id}').focus()"
  end
end
