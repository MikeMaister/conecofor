class ErrorErbacee < ActiveRecord::Base
 set_table_name "error_erbacee"

  def fill_and_save_from_file(record,error_kind,error,row,file_id)
    self.created_at = Time.now
    self.error_kind = error_kind
    self.row = row
    self.file_name_id = file_id
    self.data = record.data
    self.plot = record.cod_plot
    self.subplot = record.subplot

    self.specie = record.specie
    self.copertura = record.copertura
    self.copertura_esterna = record.copertura_esterna
    self.altezza_media = record.altezza_media
    self.numero_cespi = record.numero_cespi
    self.numero_stoloni = record.numero_stoloni
    self.numero_stoloni_radicanti = record.numero_stoloni_radicanti
    self.numero_foglie = record.numero_foglie
    self.numero_getti = record.numero_getti
    self.danni_meccanici = record.danni_meccanici
    self.danni_parassitari = record.danni_parassitari


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

    self.specie = Specie.find(record.specie_id).descrizione unless record.specie_id.blank?
    self.copertura = record.copertura
    self.copertura_esterna = record.copertura_esterna
    self.altezza_media = record.altezza_media
    self.numero_cespi = record.numero_cespi
    self.numero_stoloni = record.numero_stoloni
    self.numero_stoloni_radicanti = record.numero_stoloni_radicanti
    self.numero_foglie = record.numero_foglie
    self.numero_getti = record.numero_getti
    self.danni_meccanici = record.danni_meccanici
    self.danni_parassitari = record.danni_parassitari

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
