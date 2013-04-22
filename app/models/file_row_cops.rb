class FileRowCops
  attr_accessor :data,:cod_plot,:subplot,:in_out,:priest,:cod_strato,:specie,:copertura,:note,:substrate,:certainty_species_determination

  def initialize(data,plot,subplot,io,priest,strat,spec,cop,note,sub,csp)
    @data = data
    @cod_plot = plot
    @subplot = subplot
    @in_out = io
    @priest = priest
    @cod_strato = strat
    @specie = spec
    @copertura  = cop
    @note = note
    @substrate = sub
    @certainty_species_determination = csp
  end

  def force_data_format
    #converto i valori in interi se non nulli
    self.cod_plot = self.cod_plot.to_i if !self.cod_plot.blank?
    self.subplot = self.subplot.to_i if !self.subplot.blank?
    self.in_out = self.in_out.to_i if !self.in_out.blank?
    self.priest = self.priest.to_i if !self.priest.blank?
    self.cod_strato = self.cod_strato.to_i if !self.cod_strato.blank?
    self.substrate = self.substrate.to_i if !self.substrate.blank?
    self.certainty_species_determination = self.certainty_species_determination.to_i if !self.certainty_species_determination.blank?
    #carattere testo
    string = /\D/
    #se è un carattere di testo
    if self.copertura =~ string
      #la forzo a testo
      self.copertura = self.copertura.to_s
    #se non è un carattere di testo
    else
      #la forzo come intero
      self.copertura = self.copertura.to_i if !self.copertura.blank?
    end
  end

end
