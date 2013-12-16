class SheetFile < ActiveRecord::Base
  set_table_name "sheet_file"

  belongs_to :plot, :foreign_key => :plot_id

  def fill!(id_ril,name,survey,path,relpath,plot_id,campagna_id)
    self.rilevatore_id = id_ril
    self.name = name
    self.survey = survey
    self.path = path
    self.relative_path = relpath
    self.created_at = DateTime.now
    self.plot_id = plot_id
    self.campagna_id = campagna_id
    self.import_permit = false
  end

  def permits?
    permit = ImportPermits.find(:first,:conditions => ["rilevatore_id = ? AND year = ? AND survey = ?",self.rilevatore_id,self.year,self.survey])
    if permit.blank?
      return false
    else
      return true
    end
  end
end
