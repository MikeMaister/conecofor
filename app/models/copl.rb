class Copl < ActiveRecord::Base
  set_table_name "copl"

  def fill_temp(record,file_id,row)
    plot = Plot.find(:first,:conditions => ["numero_plot = ? AND deleted = false", record.cod_plot])
    file = ImportFile.find(file_id)

    self.id_plot = plot.id_plot
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
    self.copertura_suolo_nudo = record.cop_suol

    self.note = record.note
    self.data = record.data
    self.campagne_id = file.campagne_id
    self.plot_id = plot.id
    self.numero_plot = plot.numero_plot
    self.temp = true
    self.row = row
    self.file_name_id = file_id
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
