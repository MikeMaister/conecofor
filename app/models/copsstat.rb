class Copsstat
  attr_accessor :select,:group_by,:max_record,:min_record,:med_record,:std_record,:n_record,:ste_record,:cov_record

  def cops_filter(field,plot,anno,query_part)
    @max_record = get_max(field,plot,anno,query_part)
    @min_record = get_min(field,plot,anno,query_part)
    @med_record = get_med(field,plot,anno,query_part)
    @std_record,@n_record = get_std(field,plot,anno,query_part)
    @ste_record = get_ste(self.std_record,self.n_record)
    @cov_record = get_cov(self.std_record,self.med_record)
  end


  def query_build(inout,priest,cod_stra,spe)
    @select = ",in_out,priest,codice_strato,specie_id"#build_select!(inout,priest,cod_stra,spe)
    @group_by = build_group_by!(inout,priest,cod_stra,spe)
  end

  private

  def build_select!(inout,priest,cod_stra,spe)
    string = ""
    string = string + ",in_out" if inout.to_i == 1
    string = string + ",priest" if priest.to_i == 1
    string = string + ",codice_strato" if cod_stra.to_i == 1
    string = string + ",specie_id" if spe.to_i == 1
    return string
  end

  def build_group_by!(inout,priest,cod_stra,spe)
    string = ""
    string = string + "in_out" if inout.to_i == 1 && string == ""
    string = string + "priest" if priest.to_i == 1 && string == ""
    string = string + "codice_strato" if cod_stra.to_i == 1 && string == ""
    string = string + "specie_id" if spe.to_i == 1 && string == ""

    string = string + ",in_out" if inout.to_i == 1 && string != ""
    string = string + ",priest" if priest.to_i == 1 && string != ""
    string = string + ",codice_strato" if cod_stra.to_i == 1 && string != ""
    string = string + ",specie_id" if spe.to_i == 1 && string != ""
    return string
  end

  def get_max(field,plot,anno,query_part)
    record = Cops.find_by_sql ["SELECT MAX(#{field}) AS maximus #{query_part.select} FROM cops,copertura_specifica WHERE copertura_specifica.id = copertura_specifica_id AND plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY #{query_part.group_by}",plot,anno]
    return record
  end

  def get_min(field,plot,anno,query_part)
    record = Cops.find_by_sql ["SELECT MIN(#{field}) AS min #{query_part.select} FROM cops,copertura_specifica WHERE copertura_specifica.id = copertura_specifica_id AND plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY #{query_part.group_by}",plot,anno]
    return record
  end

  def get_med(field,plot,anno,query_part)
    record = Cops.find_by_sql ["SELECT AVG(#{field}) AS med FROM cops,copertura_specifica WHERE copertura_specifica.id = copertura_specifica_id AND plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY #{query_part.group_by}",plot,anno]
    return record
  end

  def get_std(field,plot,anno,query_part)
    std_rec = Cops.find_by_sql ["SELECT STDDEV(#{field}) AS std FROM cops,copertura_specifica WHERE copertura_specifica.id = copertura_specifica_id AND plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY #{query_part.group_by}",plot,anno]
    n_rec  = Cops.find_by_sql ["SELECT COUNT(#{field}) AS n FROM cops,copertura_specifica WHERE copertura_specifica.id = copertura_specifica_id AND plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY #{query_part.group_by}",plot,anno]
   return std_rec,n_rec
  end

  def get_ste(std_record,n_record)
    ste_rec = Array.new
    for i in 0..std_record.size-1
      ste = std_record.at(i).std.to_f/Math.sqrt(n_record.at(i).n.to_i)
      ste_rec << ste.to_f.round_with_precision(2)
    end
    return ste_rec
  end

  def get_cov(std_record,med_record)
    #mettere che se la media == 0 note impossibile calcolare il coefficente di variazione
    cov_rec = Array.new
    for i in 0..std_record.size-1
      cov = std_record.at(i).std.to_f/med_record.at(i).med.to_f.abs
      cov_rec << cov.to_f.round_with_precision(2)
    end
    return cov_rec
  end

end
