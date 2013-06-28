class ImportPermits < ActiveRecord::Base
  set_table_name "import_permits"

  def fill_and_save!(ril_id,year,survey)
    self.rilevatore_id = ril_id
    self.year = year
    self.survey = survey
    self.created_at = DateTime.now
    self.save
  end

end
