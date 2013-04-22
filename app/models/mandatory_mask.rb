class MandatoryMask < ActiveRecord::Base
  set_table_name "mandatory_mask"

  def fill_and_save(survey,name,time,parameter)
    self.survey = survey
    self.parameter = parameter
    self.mask_name = name
    self.created_at = time
    self.deleted = false
    self.save
  end

  def delete_it!
    self.deleted = true
    self.save
  end

end
