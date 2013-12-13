module SurveySheetHelper
  def red_green(td_element)
    if td_element.blank?
      content_tag(:td, "#{td_element}", :class => "red")
    else
      content_tag(:td, "#{td_element}", :class => "green")
    end
  end

end
