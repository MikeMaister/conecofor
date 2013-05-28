class Copsstat
  attr_accessor :select,:group_by,:max_record

  def cops_filter(field,plot,anno,query_part)
    @max_record = get_max(field,plot,anno,query_part)
    #@min
    #@med
    #@std,@n = nil,nil
    #@ste
    #@cov,@note = nil,nil
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

end
