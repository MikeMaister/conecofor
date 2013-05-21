class ErrorCopl < ActiveRecord::Base
  set_table_name "error_copl"

  def fill_and_save_from_file(record,error_kind,error,file_id,row)
    self.created_at = Time.now
    self.error_kind = error_kind
    self.row = row
    self.file_name_id = file_id
    self.data = record.data
    self.plot = record.cod_plot
    self.subplot = record.subplot
    self.in_out = record.in_out
    self.priest = record.priest

    self.copertura_complessiva = record.cop_comp
    self.altezza_arboreo = record.alt_arbo
    self.copertura_arboreo = record.cop_arbo
    self.altezza_arbustivo = record.alt_arbu
    self.copertura_arbustivo = record.cop_arbu
    self.altezza_erbaceo = record.alt_erb
    self.copertura_erbaceo = record.cop_erb
    self.copertura_muscinale = record.cop_musc
    self.copertura_lettiera = record.cop_lett
    self.copertura_suolo = record.cop_suol

    self.note = record.note
    self.import_num = ImportFile.find(file_id).import_num
    self.error = error
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

    self.copertura_complessiva = record.copertura_complessiva
    self.altezza_arboreo = record.altezza_arboreo
    self.copertura_arboreo = record.copertura_arboreo
    self.altezza_arbustivo = record.altezza_arbustivo
    self.copertura_arbustivo = record.copertura_arbustivo
    self.altezza_erbaceo = record.altezza_erbaceo
    self.copertura_erbaceo = record.copertura_erbaceo
    self.copertura_muscinale = record.copertura_muscinale
    self.copertura_lettiera = record.copertura_lettiera
    self.copertura_suolo = record.copertura_suolo_nudo

    self.note = record.note
    self.import_num = ImportFile.find(file_id).import_num
    self.error = error
    self.deleted = false
    self.save
  end

  def global_error_fill_and_save(error,file)
    self.created_at = Time.now
    self.error_kind = "Global Error"
    self.error = error
    self.file_name_id = file.id
    self.import_num = file.import_num
    self.deleted = false
    self.save
  end

  def force_it!
    self.forced = true
    self.save
  end

end
