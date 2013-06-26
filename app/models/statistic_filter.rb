class StatisticFilter < Statistic
  attr_accessor :inout,:priest,:cod_strato,:specie,:subplot,:eucode,:eudesc

  def initialize()
    @inout,@priest,@cod_strato,@specie,@subplot = nil,nil,nil,nil,nil
  end

  def set_filter!(stats)
    @subplot = stats.subplot unless stats.subplot.blank?
    @inout = stats.in_out unless stats.in_out.blank?
    @priest = stats.priest unless stats.priest.blank?
    @cod_strato = stats.cod_strato unless stats.cod_strato.blank?
    @specie = stats.specie unless stats.specie.blank?
    @eucode = stats.eucode unless stats.specie.blank? || stats.eucode.blank?
    @eudesc = stats.eudesc unless stats.specie.blank? || stats.eudesc.blank?
  end

  def set_less_filter!(stats)
    @inout = stats.in_out unless stats.in_out.blank?
    @priest = stats.priest unless stats.priest.blank?
  end

  def set_specie_filter!(stats)
    @specie = stats.specie unless stats.specie.blank?
    @eucode = stats.eucode unless stats.specie.blank? || stats.eucode.blank?
    @eudesc = stats.eudesc unless stats.specie.blank? || stats.eudesc.blank?
  end

end
