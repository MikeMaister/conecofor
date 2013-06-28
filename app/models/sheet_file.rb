class SheetFile < ActiveRecord::Base
  set_table_name "sheet_file"

  def fill_and_save!(id_ril,name,survey,year,path,relpath)
    self.rilevatore_id = id_ril
    self.name = name
    self.survey = survey
    self.year = year
    self.path = path
    self.relative_path = relpath
    self.created_at = DateTime.now
    self.save
  end
end
