class StatisticSu
  attr_accessor :anno,:plot,:eucode,:eudesc,:specie,:subplot,:copertura,:individui

  def initialize()
    @anno = nil
    @plot = nil
    @eucode = nil
    @eudesc = nil
    @specie = nil
    @subplot = nil
    @copertura = nil
    @individui = nil
  end

  def fill_erb(data,anno)
    @anno = anno
    @subplot = data.subplot
    @plot = data.plot
    @eucode = data.eucode
    @eudesc = data.eudesc
    @specie = data.specie
    @copertura = data.copertura
    @individui = set_individui(data)
  end

  def fill_leg(data)
    @anno = anno
    @plot = data.plot
    @subplot = data.subplot
    @eucode = data.eucode
    @eudesc = data.eudesc
    @specie = data.specie
    @copertura = data.copertura
    @individui = data.individui
  end

  def fill_cops(data)
    @anno = anno
    @plot = data.plot
    @subplot = data.subplot
    @eucode = data.eucode
    @eudesc = data.eudesc
    @specie = data.specie
    @copertura = data.copertura.to_f.round_with_precision(2)
    @individui = data.individui
  end


  private

  def set_individui(data)
    if data.n_c.blank?
      cespi = 0
    else
      cespi = data.n_c
    end
    if data.n_s.blank?
      stoloni = 0
    else
      stoloni = data.n_s
    end
    if data.n_g.blank?
      getti = 0
    else
      getti = data.n_g
    end
    return cespi.to_i + stoloni.to_i + getti.to_i
  end
end
