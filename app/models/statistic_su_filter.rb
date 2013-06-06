class StatisticSuFilter < StatisticSu
  attr_accessor :inout,:priest,:cod_strato

  def initialize()
    @inout,@priest,@cod_strato = nil,nil,nil
  end

  def fill_it!(data,anno)
    @anno = anno
    @plot = data.plot
    @subplot = data.subplot
    @eucode = data.eucode
    @eudesc = data.eudesc
    @specie = data.specie
    @copertura = data.copertura.to_f.round_with_precision(2)
    @individui = data.individui
    @inout = data.in_out unless data.in_out.blank?
    @priest = data.priest unless data.priest.blank?
    @cod_strato = data.codice_strato unless data.codice_strato.blank?
  end


end
