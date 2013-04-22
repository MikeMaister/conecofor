class FileRowErbacee < ActiveRecord::Base
  attr_accessor :data,:cod_plot,:subplot,:specie,:copertura_esterna,:copertura,:altezza_media,:numero_cespi,:numero_stoloni,:numero_stoloni_radicanti,:numero_foglie,:numero_getti,:danni_meccanici,:danni_parassitari,:note

  def initialize(data,plot,subplot,specie,copertura,copertura_esterna,altezza_media,n_cespi,n_stoloni,n_stoloni_rad,n_foglie,n_getti,danni_meccanici,danni_parassitari,note)
    @data = data
    @cod_plot = plot
    @subplot = subplot
    @specie = specie
    @copertura = copertura
    @copertura_esterna = copertura_esterna
    @altezza_media = altezza_media
    @numero_cespi = n_cespi
    @numero_stoloni = n_stoloni
    @numero_stoloni_radicanti = n_stoloni_rad
    @numero_foglie = n_foglie
    @numero_getti = n_getti
    @danni_meccanici = danni_meccanici
    @danni_parassitari = danni_parassitari
    @note = note
  end

  def force_data_format
    #converto i valori in interi se non nulli
    self.cod_plot = self.cod_plot.to_i if !self.cod_plot.blank?
    self.subplot = self.subplot.to_i if !self.subplot.blank?
    self.copertura = self.copertura.to_i if !self.copertura.blank?
    self.copertura_esterna = self.copertura_esterna.to_i if !self.copertura_esterna.blank?
    self.numero_cespi = self.numero_cespi.to_i if !self.numero_cespi.blank?
    self.numero_stoloni = self.numero_stoloni.to_i if !self.numero_stoloni.blank?
    self.numero_stoloni_radicanti = self.numero_stoloni_radicanti.to_i if !self.numero_stoloni_radicanti.blank?
    self.numero_foglie = self.numero_foglie.to_i if !self.numero_foglie.blank?
    self.numero_getti = self.numero_getti.to_i if !self.numero_getti.blank?
    self.danni_meccanici = self.danni_meccanici.to_i if !self.danni_meccanici.blank?
    self.danni_parassitari = self.danni_parassitari.to_i if !self.danni_parassitari.blank?
  end
end
