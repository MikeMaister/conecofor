class SimpleRangeModel < ActiveRecord::Base
  set_table_name "simple_range_model"

  has_many :simple_range_associations, :foreign_key => :simple_range_model_id

  def fill_and_save(nome,reference_table,attribute,min,max,data_time)
    self.nome = nome
    self.created_at = data_time
    self.reference_table = reference_table
    self.attr = attribute
    self.min = min
    self.max = max
    self.deleted = false
    self.save
  end

  def delete!
    self.deleted = true
    self.save
  end

end
