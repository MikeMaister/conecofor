class SimpleRangeAssociation < ActiveRecord::Base
  set_table_name "simple_range_association"

  def new_camp_srm_association(camp_id,srm_row_id)
    self.campagna_id = camp_id
    self.simple_range_model_id = srm_row_id
    self.deleted = false
    self.save
  end

  def delete_it!
    self.deleted = true
    self.save
  end

end
