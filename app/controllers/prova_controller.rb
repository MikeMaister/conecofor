class ProvaController < ApplicationController
 include Query_build
  def index
    @asd = in_all_plot_id
    @field = "copertura_complessiva"
    @plot = 3
    @anno = 2011
    @inout,@priest,@cod_strato,@specie = 1,1,1,1
    query_part = build_group_by_2!(@inout,@priest)
    data = Copl.find_by_sql ["SELECT id_plot as plot,in_out,priest,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM copl WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY #{query_part}",@plot,@anno]
    @stat_list = format_data_filter(data)
  end

private

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

 def build_group_by_2!(inout,priest)
   string = ""
   string = string + "in_out" if inout.to_i == 1 && string == ""
   string = string + "priest" if priest.to_i == 1 && string == ""
   string = string + ",in_out" if inout.to_i == 1 && string != ""
   string = string + ",priest" if priest.to_i == 1 && string != ""

   return string
 end

 def format_data_filter(data)
   stat_list = Array.new
   for i in 0..data.size-1
     stat = StatisticFilter.new
     stat.set_it!(data.at(i))
     stat.set_less_filter!(data.at(i))
     stat_list << stat
   end
   return stat_list
 end

end
