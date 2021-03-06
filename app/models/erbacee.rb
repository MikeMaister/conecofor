class Erbacee < ActiveRecord::Base
  set_table_name "erbacee"

  def fill_temp(record,file_id,row)
    plot = Plot.find(:first,:conditions => ["numero_plot = ? AND deleted = false", record.cod_plot])
    specie = Specie.find(:first, :conditions => ["descrizione = ? AND deleted = false", record.specie]) unless record.specie.blank?
    file = ImportFile.find(file_id)

    self.id_plot = plot.id_plot
    self.subplot = record.subplot
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
    self.data = record.data
    self.campagne_id = file.campagne_id
    self.specie_id = specie.id unless specie.blank?
    self.plot_id = plot.id
    self.numero_plot = plot.numero_plot
    self.temp = true
    self.file_name_id = file_id
    self.row = row
    self.import_num = file.import_num
    self.approved = false
    self.deleted = false
    self.save
  end

  def permanent!
    self.temp = false
    self.save
  end

  def approve_it!
    self.approved = true
    self.save
  end

end
