class EuStat
  attr_accessor :nplot,:unita,:niferb,:nifleg,:coperb,:copbrio,:coplich,:copleg,
                :nspecerb,:nspecbrio,:nspeclich,:nspecleg

  def initialize()
    @nplot = nil
    @unita = nil
    @niferb = nil
    @nifleg = nil
    @coperb = nil
    @copbrio = nil
    @coplich = nil
    @copleg = nil
    @nspecerb = nil
    @nspecbrio = nil
    @nspeclich = nil
    @nspecleg = nil
  end

  def set_nplot(data)
    self.nplot = data.numero_plot
  end

  def set_unita(data)
    self.unita = data.n_su
  end

  def set_niferb(data)
    self.niferb = data.niferb
  end

  def set_nifleg(data)
    self.nifleg = data.nifleg
  end

  def set_coperb(data)
    if data.coperb.blank?
      self.coperb = 0
    else
      self.coperb = data.coperb
    end
  end

  def set_copbrio(data)
    if data.copbrio.blank?
      self.copbrio = 0
    else
      self.copbrio = data.copbrio
    end
  end

  def set_coplich(data)
    if data.coplich.blank?
      self.coplich = 0
    else
      self.coplich = data.coplich
    end
  end

  def set_copleg(data)
    self.copleg = data.copleg
  end

  def set_nspecerb(data)
    if data.nspecerb.blank?
      self.nspecerb = 0
    else
      self.nspecerb = data.nspecerb
    end
  end

  def set_nspecbrio(data)
    if data.nspecbrio.blank?
      self.nspecbrio = 0
    else
      self.nspecbrio = data.nspecbrio
    end
  end

  def set_nspeclich(data)
    if data.nspeclich.blank?
      self.nspeclich = 0
    else
      self.nspeclich = data.nspeclich
    end
  end

  def set_nspecleg(data)
    self.nspecleg = data.nspecleg
  end



end
