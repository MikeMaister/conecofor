class FileRowCopl
  attr_accessor :data,:cod_plot,:subplot,:in_out,:priest,:cop_comp,:alt_arbo,:cop_arbo,:alt_arbu,:cop_arbu,:alt_erb,:cop_erb,:cop_musc,:cop_lett,:cop_suol,:note

  def initialize(data,plot,subplot,io,priest,cop_comp,alt_arbo,cop_arbo,alt_arbu,cop_arbu,alt_erb,cop_erb,cop_musc,cop_lett,cop_suol,note)
    @data = data
    @cod_plot = plot
    @subplot = subplot
    @in_out = io
    @priest = priest
    @cop_comp = cop_comp
    @alt_arbo = alt_arbo
    @cop_arbo = cop_arbo
    @alt_arbu = alt_arbu
    @cop_arbu = cop_arbu
    @alt_erb = alt_erb
    @cop_erb = cop_erb
    @cop_musc = cop_musc
    @cop_lett = cop_lett
    @cop_suol = cop_suol
    @note = note
  end

  def force_data_format
    #converto i valori in interi se non nulli
    self.cod_plot = self.cod_plot.to_i if !self.cod_plot.blank?
    self.subplot = self.subplot.to_i if !self.subplot.blank?
    self.in_out = self.in_out.to_i if !self.in_out.blank?
    self.priest = self.priest.to_i if !self.priest.blank?
    self.cop_comp = self.cop_comp.to_i if !self.cop_comp.blank?
    self.alt_arbo = self.alt_arbo.to_i if !self.alt_arbo.blank?
    self.cop_arbo = self.cop_arbo.to_i if !self.cop_arbo.blank?
    self.cop_erb = self.cop_erb.to_i if !self.cop_erb.blank?
    self.cop_lett = self.cop_lett.to_i if !self.cop_lett.blank?
  end
end
