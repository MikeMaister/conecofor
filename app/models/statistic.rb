class Statistic
  attr_accessor :max,:min,:med,:std,:ste,:cov,:n

  def single_plot(survey,field,plot,anno)
    @max = get_smaximum(survey,field,plot,anno)
    @min = get_sminimum(survey,field,plot,anno)
    @med = get_smed(survey,field,plot,anno)
    @std,@n = get_std(survey,field,plot,anno,self.med)
    @ste = standard_error(self.n,self.std)
    @cov = coefficent_of_variation(self.std,self.med)
  end

  def all_plot(survey,field,anno)
  end

  private

  def get_smaximum(survey,field,plot,anno)
    case survey
      when "erb"
        if field == "nif"
          m1 = Erbacee.find_by_sql ["SELECT MAX(numero_cespi) AS maximus FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          m2 = Erbacee.find_by_sql ["SELECT MAX(numero_stoloni) AS maximus FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          m3 = Erbacee.find_by_sql ["SELECT MAX(numero_getti) AS maximus FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          max = m1.at(0).maximus.to_i + m2.at(0).maximus.to_i + m3.at(0).maximus.to_i
          return max
        else
          max = Erbacee.find_by_sql ["SELECT MAX(#{field}) AS maximus FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          return max.at(0).maximus
        end
      when "leg"
        max = Legnose.find_by_sql ["SELECT MAX(#{field}) AS maximus FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
      when "copl"
        max = Copl.find_by_sql ["SELECT MAX(#{field}) AS maximus FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
      when "cops"
        max = Cops.find_by_sql ["SELECT MAX(#{field}) AS maximus FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
    end
  end

  def get_sminimum(survey,field,plot,anno)
    case survey
      when "erb"
        if field == "nif"
          m1 = Erbacee.find_by_sql ["SELECT MIN(numero_cespi) AS min FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          m2 = Erbacee.find_by_sql ["SELECT MIN(numero_stoloni) AS min FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          m3 = Erbacee.find_by_sql ["SELECT MIN(numero_getti) AS min FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          min = m1.at(0).min.to_i + m2.at(0).min.to_i + m3.at(0).min.to_i
          return min
        else
          min = Erbacee.find_by_sql ["SELECT MIN(#{field}) AS min FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          return min.at(0).min
        end
      when "leg"
        min = Legnose.find_by_sql ["SELECT MIN(#{field}) AS min FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
      when "copl"
        min = Copl.find_by_sql ["SELECT MIN(#{field}) AS min FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
      when "cops"
        max = Cops.find_by_sql ["SELECT MIN(#{field}) AS min FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
    end
  end

  def get_smed(survey,field,plot,anno)
    case survey
      when "erb"
        if field == "nif"
          m1 = Erbacee.find_by_sql ["SELECT ( SUM(numero_cespi) / COUNT(*) ) AS med FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          m2 = Erbacee.find_by_sql ["SELECT ( SUM(numero_stoloni) / COUNT(*) ) AS med FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          m3 = Erbacee.find_by_sql ["SELECT ( SUM(numero_getti) / COUNT(*) ) AS med FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          med = m1.at(0).med.to_f + m2.at(0).med.to_f + m3.at(0).med.to_f
          med = med.to_f.round_with_precision(2)
          return med
        else
          med = Erbacee.find_by_sql ["SELECT ( SUM(#{field}) / COUNT(*) ) AS med FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          med = med.at(0).med.to_f.round_with_precision(2)
          return med
        end
      when "leg"
        med = Legnose.find_by_sql ["SELECT AVG(#{field}) AS med FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
      when "copl"
        med = Copl.find_by_sql ["SELECT AVG(#{field}) AS med FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
      when "cops"
        med = Cops.find_by_sql ["SELECT AVG(#{field}) AS med FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
    end
  end

  def get_std(survey,field,plot,anno,med)
    case survey
      when "erb"
        if field == "nif"
          #m1 = Erbacee.find_by_sql ["SELECT AVG(numero_cespi) AS med FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          #m2 = Erbacee.find_by_sql ["SELECT AVG(numero_stoloni) AS med FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          #m3 = Erbacee.find_by_sql ["SELECT AVG(numero_getti) AS med FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          #med = m1.at(0).med.to_f + m2.at(0).med.to_f + m3.at(0).med.to_f
          #med = med.to_f.round_with_precision(2)
          #return med
        else
          data = Erbacee.find_by_sql ["SELECT #{field} AS field FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
          return standard_deviation(data,med), data.size
        end
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
    cov = std / (med.abs)
    return cov.to_f.round_with_precision(2)
  end

end
