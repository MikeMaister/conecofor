class Erbstat
  attr_accessor :max,:min,
                :med,:med1,:med2,:med3,
                :std,:std1,:std2,:std3,
                :ste,:cov,:n,:note

  def single_plot(plot,anno)
    @max = get_smaximum(plot,anno)
    @min = get_sminimum(plot,anno)
    @med,@med1,@med2,@med3 = get_smed(plot,anno)
    @std,@n,@std1,@std2,@std3 = get_std(plot,anno,self.med1,self.med2,self.med3)
    @ste = get_standard_error(self.std1,self.std2,self.std3,self.n)
    @cov,@note = get_cov(self.std1,self.std2,self.std3,self.med1,self.med2,self.med3)
  end

  private

  def get_smaximum(plot,anno)
    m1 = Erbacee.find_by_sql ["SELECT MAX(numero_cespi) AS maximus FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
    m2 = Erbacee.find_by_sql ["SELECT MAX(numero_stoloni) AS maximus FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
    m3 = Erbacee.find_by_sql ["SELECT MAX(numero_getti) AS maximus FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
    max = m1.at(0).maximus.to_i + m2.at(0).maximus.to_i + m3.at(0).maximus.to_i
    return max
  end

  def get_sminimum(plot,anno)
    m1 = Erbacee.find_by_sql ["SELECT MIN(numero_cespi) AS min FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
    m2 = Erbacee.find_by_sql ["SELECT MIN(numero_stoloni) AS min FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
    m3 = Erbacee.find_by_sql ["SELECT MIN(numero_getti) AS min FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
    min = m1.at(0).min.to_i + m2.at(0).min.to_i + m3.at(0).min.to_i
    return min
  end

  def get_smed(plot,anno)
    m1 = Erbacee.find_by_sql ["SELECT ( SUM(numero_cespi) / COUNT(*) ) AS med FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
    m2 = Erbacee.find_by_sql ["SELECT ( SUM(numero_stoloni) / COUNT(*) ) AS med FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
    m3 = Erbacee.find_by_sql ["SELECT ( SUM(numero_getti) / COUNT(*) ) AS med FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
    med = m1.at(0).med.to_f + m2.at(0).med.to_f + m3.at(0).med.to_f
    med = med.to_f.round_with_precision(2)
    return med,
            m1.at(0).med.to_f.round_with_precision(2),
            m2.at(0).med.to_f.round_with_precision(2),
            m3.at(0).med.to_f.round_with_precision(2)
  end

  def get_std(plot,anno,med1,med2,med3)
    data1 = Erbacee.find_by_sql ["SELECT numero_cespi AS field FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
    p1 = standard_deviation(data1,med1)
    data2 = Erbacee.find_by_sql ["SELECT numero_stoloni AS field FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
    p2 = standard_deviation(data2,med2)
    data3 = Erbacee.find_by_sql ["SELECT numero_getti AS field FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ?) AND temp = false AND approved = true AND deleted = false",plot,anno]
    p3 = standard_deviation(data3,med3)
    return p1+p2+p3,data1.size,p1,p2,p3
  end

  def get_standard_error(std1,std2,std3,n)
    ste1 = standard_error(n,std1)
    ste2 = standard_error(n,std2)
    ste3 = standard_error(n,std3)
    ste = ste1 + ste2 + ste3
    return ste
  end

  def get_cov(std1,std2,std3,med1,med2,med3)
    cov1,note1 = coefficent_of_variation(std1,med1)
    cov2,note2 = coefficent_of_variation(std2,med2)
    cov3,note3 = coefficent_of_variation(std3,med3)

    if cov1.blank? && cov2.blank? && cov3.blank?
      cov = nil
    else
      cov1 = 0 if cov1.blank?
      cov2 = 0 if cov2.blank?
      cov3 = 0 if cov3.blank?
    end
    cov = cov1 + cov2 + cov3
    note = "" + note1 + " " + note2 + " " + note3
    return cov,note
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
      return cov.to_f.round_with_precision(2),""
    end
  end

end
