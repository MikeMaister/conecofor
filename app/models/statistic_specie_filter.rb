class StatisticSpecieFilter < StatisticSpecie
  attr_accessor :inout,:priest,:cod_strato

  def initialize()
    @inout,@priest,@cod_strato = nil,nil,nil
  end

  def fill_it!(data)
    @plot = data.plot
    @eucode = data.eucode
    @eudesc = data.eudesc
    @specie = data.specie
    @individui = data.individui
    @inout = data.in_out unless data.in_out.blank?
    @priest = data.priest unless data.priest.blank?
    @cod_strato = data.codice_strato unless data.codice_strato.blank?
  end

end
