class StatisticSpecie
  attr_accessor :plot,:eucode,:eudesc,:specie,:individui

  def initialize
    @plot = nil
    @eucode = nil
    @eudesc = nil
    @specie = nil
    @individui = nil
  end

  def fill_erb(data)
    @plot = data.plot
    @eucode = data.eucode
    @eudesc = data.eudesc
    @specie = data.specie
    @individui = set_individui(data)
  end

  def fill_leg(data)
    @plot = data.plot
    @eucode = data.eucode
    @eudesc = data.eudesc
    @specie = data.specie
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
