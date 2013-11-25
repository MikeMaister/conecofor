class MandatoryMaskAssociation < ActiveRecord::Base
  set_table_name "mandatory_mask_association"

  belongs_to :campagne, :foreign_key => :campagna_id
  belongs_to :mandatory_mask, :foreign_key => :mandatory_mask_id

  def new_camp_mm_association(camp_id,mm_row_id)
    self.campagna_id = camp_id
    self.mandatory_mask_id = mm_row_id
    self.deleted = false
    self.save
  end

  def delete_it!
    self.deleted = true
    self.save
  end

end
