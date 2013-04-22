class Vem #< ActiveRecord::Base
  attr_accessor :plot_sequenze_number,:plot_number,:sample_id,:survey_number,:species_code,:layer,:substrate,:cover_species_layer,:species_determination,:other_observations

  def initialize(record,id_count,area)
    #indice AI (come un id)
    @plot_sequenze_number = id_count
    #01ABR5 => 01
    @plot_number = get_plot_number(record.plot_id)
    #1,2,3 o 4 a seconda se è un plot interno o esterno e se l'area è 400 o 1200
    @sample_id = get_sample_id(area,record.in_out)
    #1,2,3 o 4 a seconda di stagione e in/out
    @survey_number = set_survey_number(record)
    #codice eu della specie
    @species_code = Euflora.find(Specie.find(record.specie_id).euflora_id).codice_eu
    #codice_strato
    @layer = record.codice_strato
    #substrate
    @substrate = SubstrateType.find(record.substrate_type_id).code unless record.substrate_type_id.blank?
    #copertura_specifica
    @cover_species_layer = set_result(record.tot_copertura,area) #record.tot_copertura #CoperturaSpecifica.find(record.copertura_specifica_id).value unless record.copertura_specifica_id.blank?
    #certainty of species determination
    @species_determination = CertaintySpeciesDetermination.find(record.certainty_species_determination_id).code unless record.certainty_species_determination_id.blank?
    #note
    @other_observations = set_note(record,area)
  end

  private

  def set_note(record,area)
    note = Cops.find(:all, :conditions => ["campagne_id = ? and plot_id = ? and in_out = ? and priest = ? and specie_id = ? and codice_strato = ? and approved = true and deleted = false and temp = false",record.campagne_id,record.plot_id,record.in_out,record.priest,record.specie_id,record.codice_strato])
    note_list = "[#{area}]"
    for i in 0..note.size-1
      note_list = note_list + " #{i+1})#{note.at(i).note}" unless note.at(i).note.blank?
    end
    return note_list
  end

  def set_result(a,area)
    case area
      when 400
        b = 4
      when 1200
        b = 12
    end
    c = a.to_f / b
    c = c.to_f.round_with_precision(2)
  end

  def get_plot_number(plot_id)
    plot = Plot.find(plot_id)
    if plot.numero_plot <= 9
      plot_number = "" + "0" + "#{plot.numero_plot}"
    else
      plot_number = plot.numero_plot
    end
    return plot_number
  end

  def get_sample_id(su_area,in_out)
    if su_area == 400 && in_out == 1
      sample_id = 1
    elsif su_area == 400 && in_out == 2
      sample_id = 2
    elsif su_area == 1200 && in_out == 1
      sample_id = 3
    elsif su_area == 1200 && in_out == 2
      sample_id = 4
    end
    return sample_id
  end

  def set_survey_number(record)
    if record.priest == 1 && record.in_out == 1
      survey_number = 1
    elsif record.priest == 1 && record.in_out == 2
      survey_number = 2
    elsif record.priest == 2 && record.in_out == 1
      survey_number = 3
    elsif record.priest == 2 && record.in_out == 2
      survey_number = 4
    end
    return survey_number
  end

end
