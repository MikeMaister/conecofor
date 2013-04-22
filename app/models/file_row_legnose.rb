class FileRowLegnose < ActiveRecord::Base
  attr_accessor :data,:cod_plot,:subplot,:specie,:copertura,:altezza,:eta_strutturale,:danni_meccanici,:danni_parassitari,:radicanti,:note

  def initialize(data,plot,subplot,specie,copertura,altezza,eta_strutturale,danni_meccanici,danni_parassitari,radicanti,note)
    @data = data
    @cod_plot = plot
    @subplot = subplot
    @specie = specie
    @copertura = copertura
    @altezza = altezza
    @eta_strutturale = eta_strutturale
    @danni_meccanici = danni_meccanici
    @danni_parassitari = danni_parassitari
    @radicanti = radicanti
    @note = note
  end

  def force_data_format
    #converto i valori in interi se non nulli
    self.cod_plot = self.cod_plot.to_i if !self.cod_plot.blank?
    self.subplot = self.subplot.to_i if !self.subplot.blank?
    self.copertura = self.copertura.to_i if !self.copertura.blank?
    self.eta_strutturale = self.eta_strutturale.to_i if !self.eta_strutturale.blank?
    self.danni_meccanici = self.danni_meccanici.to_i if !self.danni_meccanici.blank?
    self.danni_parassitari = self.danni_parassitari.to_i if !self.danni_parassitari.blank?
    self.radicanti = self.radicanti.to_i if !self.radicanti.blank?
  end
end
