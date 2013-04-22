class OutputFile < ActiveRecord::Base
  set_table_name "output_file"

  def fill_and_save(file_name,complete_path,relative_path,file_type)
    self.file_name = file_name
    self.path = complete_path
    self.relative_path = relative_path
    self.file_type = file_type
    self.created_at = Time.now
    self.save
  end

end
