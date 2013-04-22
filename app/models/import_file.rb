class ImportFile < ActiveRecord::Base
  set_table_name "import_file"

  def fill_and_save(file_name,campagne_id,file_path,survey_kind,user,plot_number)
    self.file_name = file_name
    self.campagne_id = campagne_id
    self.path = file_path
    self.created_at = Time.now
    self.import_num = 1
    self.survey_kind = survey_kind
    self.user_id = user
    self.plot_number = plot_number
    self.deleted = false
    self.save
  end

  def update_and_save
    self.updated_at = Time.now
    self.import_num = self.import_num + 1
    self.save
  end

  def delete_it!
    self.deleted = true
    self.save
  end

end
