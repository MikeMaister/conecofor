class Statistic
  attr_accessor :max,:min,:med,:std,:ste,:cov,:n,:note

  def single_plot(survey,field,plot,anno)
    @max = get_smaximum(survey,field,plot,anno)
    @min = get_sminimum(survey,field,plot,anno)
    @med = get_smed(survey,field,plot,anno)
    @std,@n = get_std(survey,field,plot,anno,self.med)
    @ste = standard_error(self.n,self.std)
    @cov,@note = coefficent_of_variation(self.std,self.med)
  end

  private

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
