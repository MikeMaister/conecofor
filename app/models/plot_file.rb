class PlotFile < ActiveRecord::Base
  set_table_name "plot_file"

  def initiate()
    self.file_name = nil
    self.created_at = nil
    self.path = nil
    self.relative_path = nil
    self.description = nil
    self.plot_id = nil
  end

  def fill_and_save!(name,path,rel_path,desc,plot)
    self.file_name = name
    self.created_at = Time.now
    self.path = path
    self.relative_path = rel_path
    self.description = desc
    self.plot_id = plot
    self.save
  end

end
