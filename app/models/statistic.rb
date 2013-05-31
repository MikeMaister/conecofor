class Statistic
  attr_accessor :max,:min,:med,:std,:ste,:cov,:n,:note,:plot

  def initialize()
    @plot = nil
    @max = nil
    @min = nil
    @med = nil
    @std = nil
    @n = nil
    @ste = nil
    @cov,@note = nil,nil
  end

  def set_it!(stats)
    @plot = stats.plot
    @max = stats.max.to_f.round_with_precision(2) unless stats.n.to_i == 0
    @min = stats.min.to_f.round_with_precision(2) unless stats.n.to_i == 0
    @med = stats.med.to_f.round_with_precision(2) unless stats.n.to_i == 0
    @std = stats.std.to_f.round_with_precision(2) unless stats.n.to_i == 0
    @n = stats.n.to_i
    @ste = set_ste(self.std,self.n)  unless stats.n.to_i == 0
    @cov,@note = set_cov(self.std,self.med)  unless stats.n.to_i == 0
  end

 def set_nif!(stat_cespi,stat_stoloni,stat_getti)
   @plot = stat_cespi.plot
   @max = get_max_nif(stat_cespi,stat_stoloni,stat_getti)
   @min = get_min_nif(stat_cespi,stat_stoloni,stat_getti)
   @med = get_med_nif(stat_cespi,stat_stoloni,stat_getti)
   @std = get_std_nif(stat_cespi,stat_stoloni,stat_getti)
   @n = stat_cespi.n.to_i + stat_stoloni.n.to_i + stat_getti.n.to_i
   @ste = get_ste_nif(stat_cespi,stat_stoloni,stat_getti)
   @cov,@note = get_cov_nif(stat_cespi,stat_stoloni,stat_getti)
 end

  #def single_plot(survey,field,plot,anno)
    #@max = get_smaximum(survey,field,plot,anno)
    #@min = get_sminimum(survey,field,plot,anno)
    #@med = get_smed(survey,field,plot,anno)
    #@std,@n = get_std(survey,field,plot,anno,self.med)
    #@ste = standard_error(self.n,self.std)
    #@cov,@note = coefficent_of_variation(self.std,self.med)
  #end

  private

  def set_ste(std,n)
    ste = std / Math.sqrt(n)
    return ste.to_f.round_with_precision(2)
  end

  def set_cov(std,med)
    if med == 0
      message = "Impossibile calcolare il coefficente di variazione."
      return nil,message
    else
      cov = std / (med.abs)
      return cov.to_f.round_with_precision(2),nil
    end
  end

  def get_max_nif(c,s,g)
    max_c,max_s,max_g = nil,nil,nil
    max = 0
    max_c = c.max.to_f unless c.max.blank?
    max_s = s.max.to_f unless s.max.blank?
    max_g = g.max.to_f unless g.max.blank?
    max = max + max_c unless max_c.blank?
    max = max + max_s unless max_s.blank?
    max = max + max_g unless max_g.blank?
    if c.n.to_i == 0 && s.n.to_i == 0 && g.n.to_i == 0
      return nil
    else
      return max.round_with_precision(2)
    end
  end

  def get_min_nif(c,s,g)
    min_c,min_s,min_g = nil,nil,nil
    min = 0
    min_c = c.min.to_f unless c.min.blank?
    min_s = s.min.to_f unless s.min.blank?
    min_g = g.min.to_f unless g.min.blank?
    min = min + min_c unless min_c.blank?
    min = min + min_s unless min_s.blank?
    min = min + min_g unless min_g.blank?
    if c.n.to_i == 0 && s.n.to_i == 0 && g.n.to_i == 0
      return nil
    else
      return min.round_with_precision(2)
    end
  end

  def get_med_nif(c,s,g)
    med_c,med_s,med_g = nil,nil,nil
    med = 0
    med_c = c.med.to_f unless c.med.blank?
    med_s = s.med.to_f unless s.med.blank?
    med_g = g.med.to_f unless g.med.blank?
    med = med + med_c unless med_c.blank?
    med = med + med_s unless med_s.blank?
    med = med + med_g unless med_g.blank?
    if c.n.to_i == 0 && s.n.to_i == 0 && g.n.to_i == 0
      return nil
    else
      return med.round_with_precision(2)
    end
  end

  def get_std_nif(c,s,g)
    std_c,std_s,std_g = nil,nil,nil
    std = 0
    std_c = c.std.to_f unless c.std.blank?
    std_s = s.std.to_f unless s.std.blank?
    std_g = g.std.to_f unless g.std.blank?
    std = std + std_c unless std_c.blank?
    std = std + std_s unless std_s.blank?
    std = std + std_g unless std_g.blank?
    if c.n.to_i == 0 && s.n.to_i == 0 && g.n.to_i == 0
      return nil
    else
      return std.round_with_precision(2)
    end
  end

  def get_ste_nif(c,s,g)
    ste_c,ste_s,ste_g = nil,nil,nil
    ste = 0
    ste_c = c.std.to_f / Math.sqrt(c.n.to_i) unless c.n.blank? || c.std.blank?
    ste_s = s.std.to_f / Math.sqrt(s.n.to_i) unless s.n.blank? || s.std.blank?
    ste_g = g.std.to_f / Math.sqrt(g.n.to_i) unless g.n.blank? || g.std.blank?
    ste = ste + ste_c unless ste_c.blank?
    ste = ste + ste_s unless ste_s.blank?
    ste = ste + ste_g unless ste_g.blank?
    if c.n.to_i == 0 && s.n.to_i == 0 && g.n.to_i == 0
      return nil
    else
      return ste.to_f.round_with_precision(2)
    end
  end

  def get_cov_nif(c,s,g)
    cov_c,cov_s,cov_g = nil,nil,nil
    cov = 0
    cov_c = c.std.to_f / c.med.to_f.abs unless c.med.blank? || c.med.to_f == 0 || c.std.blank?
    cov_s = s.std.to_f / s.med.to_f.abs unless s.med.blank? || s.med.to_f == 0 || s.std.blank?
    cov_g = g.std.to_f / g.med.to_f.abs unless g.med.blank? || g.med.to_f == 0 || g.std.blank?
    cov = cov + cov_c unless cov_c.blank?
    cov = cov + cov_s unless cov_s.blank?
    cov = cov + cov_g unless cov_g.blank?
    if c.n.to_i == 0 && s.n.to_i == 0 && g.n.to_i == 0
      return nil,"Impossibile calcolare il coefficente di variazione"
    else
      return cov.round_with_precision(2),nil
    end
  end



 #da eliminare tutto da qui in basso

  def get_smaximum(survey,field,plot,anno)
    case survey
      when "erb"
        max = Erbacee.find_by_sql ["SELECT MAX(#{field}) AS maximus FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",plot,anno]
        return max.at(0).maximus
      when "leg"
        max = Legnose.find_by_sql ["SELECT MAX(#{field}) AS maximus FROM legnose WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",plot,anno]
        return max.at(0).maximus
      when "cops"
        max = Cops.find_by_sql ["SELECT MAX(#{field}) AS maximus FROM cops,copertura_specifica WHERE copertura_specifica.id = copertura_specifica_id AND plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",plot,anno]
        return max.at(0).maximus
    end
  end

  def get_sminimum(survey,field,plot,anno)
    case survey
      when "erb"
        min = Erbacee.find_by_sql ["SELECT MIN(#{field}) AS min FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",plot,anno]
        return min.at(0).min
      when "leg"
        min = Legnose.find_by_sql ["SELECT MIN(#{field}) AS min FROM legnose WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",plot,anno]
        return min.at(0).min
      when "cops"
        min = Cops.find_by_sql ["SELECT MIN(#{field}) AS min FROM cops,copertura_specifica WHERE copertura_specifica.id = copertura_specifica_id AND plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",plot,anno]
        return min.at(0).min
    end
  end

  def get_smed(survey,field,plot,anno)
    case survey
      when "erb"
        med = Erbacee.find_by_sql ["SELECT ( SUM(#{field}) / COUNT(*) ) AS med FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",plot,anno]
        med = med.at(0).med.to_f.round_with_precision(2)
        return med
      when "leg"
        med = Legnose.find_by_sql ["SELECT ( SUM(#{field}) / COUNT(*) ) AS med FROM legnose WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",plot,anno]
        med = med.at(0).med.to_f.round_with_precision(2)
        return med
      when "cops"
        med = Cops.find_by_sql ["SELECT ( SUM(#{field}) / COUNT(*) ) AS med FROM cops,copertura_specifica WHERE copertura_specifica.id = copertura_specifica_id AND plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",plot,anno]
        med = med.at(0).med.to_f.round_with_precision(2)
        return med
    end
  end

  def get_std(survey,field,plot,anno,med)
    case survey
      when "erb"
        data = Erbacee.find_by_sql ["SELECT #{field} AS field FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",plot,anno]
        return standard_deviation(data,med), data.size
      when "leg"
        data = Legnose.find_by_sql ["SELECT #{field} AS field FROM legnose WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",plot,anno]
        return standard_deviation(data,med), data.size
      when "cops"
        data = Cops.find_by_sql ["SELECT #{field} AS field FROM cops,copertura_specifica WHERE copertura_specifica.id = copertura_specifica_id AND plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",plot,anno]
        return standard_deviation(data,med), data.size
    end
  end

  def standard_deviation(array,med)
    sum = 0
    array.each do |xi|
      t = (xi.field.to_f-med)
      t = t * t
      sum += t
    end
    std = Math.sqrt(sum/array.size)
    return std.to_f.round_with_precision(2)
  end

  def standard_error(n,std)
    ste = std / Math.sqrt(n)
    return ste.to_f.round_with_precision(2)
  end

  def coefficent_of_variation(std,med)
    if med == 0
      message = "Impossibile calcolare il coefficente di variazione."
      return nil,message
    else
      cov = std / (med.abs)
      return cov.to_f.round_with_precision(2),nil
    end
  end

end

