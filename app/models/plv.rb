class Plv #< ActiveRecord::Base
   attr_accessor :plot_seq_number,:country_code,:plot_number,:sample_id,:team_id,:team_members,:survey_type,:survey_number,:date,:latitude,:longitude,:altitude,:fence,:total_area,:tree_layer_cover,:shrub_layer_cover,:shrub_layer_height,:herb_layer_cover,:herb_layer_height,:mosses_cover,:bare_soil_cover,:litter_cover,:other_observations

  def initialize(plv_data_record,plv_note,plv_su_num,id_plv,su_area,in_out,season)
    @plot_seq_number = id_plv
    @country_code = 05
    @plot_number = get_plot_number(plv_data_record.plot_num)
    @sample_id = get_sample_id(su_area,in_out)
    @team_id = self.plot_number
    @team_members = 2
    @survey_type = get_survey_type(su_area)
    @survey_number = get_survey_number(in_out,season)
    @date = plv_data_record.data.strftime("%d/%m/%y")
    @latitude = plv_data_record.lat
    @longitude = plv_data_record.lon
    @altitude = plv_data_record.alt
    @fence = get_fence(in_out)
    @total_area = su_area
    @tree_layer_cover = set_result(plv_data_record.t_cop_arbo.to_i,plv_su_num.to_i,"int")
    @shrub_layer_height = set_result(plv_data_record.t_alt_arbu.to_f,plv_su_num.to_i,"float")
    @shrub_layer_cover = set_result(plv_data_record.t_cop_arbu.to_f,plv_su_num.to_i,"float")
    @herb_layer_height = set_result(plv_data_record.t_alt_erb.to_f,plv_su_num.to_i,"float")
    @herb_layer_cover = set_result(plv_data_record.t_cop_erb.to_f,plv_su_num.to_i,"float")
    @mosses_cover = set_result(plv_data_record.t_cop_musc.to_f,plv_su_num.to_i,"float")
    @bare_soil_cover = set_result(plv_data_record.t_cop_suol.to_f,plv_su_num.to_i,"float")
    @litter_cover = set_result(plv_data_record.t_cop_let.to_f,plv_su_num.to_i,"float")
    @other_observations = concat_note(plv_note,self.total_area)
  end

  private

  def set_result(a,b,type)
    c = a / b
    if type == "int"
      c = c.to_i
    elsif type == "float"
      c = c.to_f.round_with_precision(2)
    end
    if c.eql?(0.00) || c.eql?(0)
      c = nil
    else
      c
    end
  end

  def get_plot_number(plot_num)
    if plot_num.to_i <= 9
      plot_number = "" + "0" + "#{plot_num}"
    else
      plot_number = plot_num
    end
    return plot_number
  end

  def get_sample_id(su_area,in_out)
    if su_area == 400 && in_out == "in"
      sample_id = 1
    elsif su_area == 400 && in_out == "out"
      sample_id = 2
    elsif su_area == 1200 && in_out == "in"
      sample_id = 3
    elsif su_area == 1200 && in_out == "out"
      sample_id = 4
    end
    return sample_id
  end

  def get_survey_number(in_out,season)
    if in_out == "in" && season == "Primavera"
      survey_number = 1
    elsif in_out == "out" && season == "Primavera"
      survey_number = 2
    elsif in_out == "in" && season == "Estate"
      survey_number = 3
    elsif in_out == "out" && season == "Estate"
      survey_number = 4
    end
    return survey_number
  end

  def get_survey_type(su_area)
    if su_area == 400
      survey_type = 1
    elsif su_area == 1200
      survey_type = 4
    end
    return survey_type
  end

  def get_fence(in_out)
    if in_out == "in"
      fence = 1
    elsif in_out == "out"
      fence = 2
    end
    return fence
  end

  def concat_note(plv_note,total_sampled_area)
    note = "[#{total_sampled_area}]"
    for i in 0..plv_note.size-1
      note = "#{note} " + "#{i+1})" + "#{plv_note.at(i).note} " unless plv_note.at(i).note.blank?
    end
    return note
  end

end
