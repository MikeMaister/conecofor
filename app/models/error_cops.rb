class ErrorCops < ActiveRecord::Base
  set_table_name "error_cops"

  def global_error_fill_and_save(error,file)
    self.created_at = Time.now
    self.error_kind = "Global Error"
    self.error = error
    self.file_name_id = file.id
    self.import_num = file.import_num
    self.deleted = false
    self.save
  end

  def fill_and_save_from_db(record,error_kind,error,file_id)
    self.created_at = Time.now
    self.error_kind = error_kind
    self.row = record.row
    self.file_name_id = file_id
    self.data = record.data
    self.plot = Plot.find(record.plot_id).numero_plot
    self.subplot = record.subplot
    self.in_out = record.in_out
    self.priest = record.priest
    self.codice_strato = record.codice_strato
    self.specie = Specie.find(record.specie_id).descrizione unless record.specie_id.blank?
    self.copertura = CoperturaSpecifica.find(record.copertura_specifica_id).identifier unless record.copertura_specifica_id.blank?
    self.note = record.note
    self.import_num = ImportFile.find(file_id).import_num
    self.error = error
    self.substrate_code = SubstrateType.find(record.substrate_type_id).code unless record.substrate_type_id.blank?
    self.certainty_species_determination_code = CertaintySpeciesDetermination.find(record.certainty_species_determination_id).code unless record.certainty_species_determination_id.blank?
    self.deleted = false
    self.save
  end

  def fill_and_save_from_file(record,error_kind,error,row,file_id)
    self.created_at = Time.now
    self.error_kind = error_kind
    self.row = row
    self.file_name_id = file_id
    self.data = record.data
    self.plot = record.cod_plot
    self.subplot = record.subplot
    self.in_out = record.in_out
    self.priest = record.priest
    self.codice_strato = record.cod_strato
    self.specie = record.specie
    self.copertura = record.copertura
    self.note = record.note
    self.import_num = ImportFile.find(file_id).import_num
    self.error = error
    self.substrate_code = record.substrate
    self.certainty_species_determination_code = record.certainty_species_determination
    self.deleted = false
    self.save
  end

  def delete_it!
    self.deleted = true
    self.save
  end

end
