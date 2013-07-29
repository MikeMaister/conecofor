class Admin::StatisticsController < ApplicationController

  def index
    @plot = Plot.find(:all,:conditions => "deleted = false",:order => "id_plot")
    @anno = Campagne.find_by_sql "SELECT DISTINCT(anno) FROM campagne WHERE deleted = false ORDER BY anno"

  end

  def update_field
    survey = params[:selected_survey]
    case survey
      when "erb"
        render :update do |page|
          page.replace_html "select_field", :partial => "erb_field"
        end
      when "leg"
        render :update do |page|
          page.replace_html "select_field", :partial => "leg_field"
        end
      when "cops"
        render :update do |page|
          page.replace_html "select_field", :partial => "cops_field"
        end
      when "copl"
        render :update do |page|
          page.replace_html "select_field", :partial => "copl_field"
        end
      else
    end
  end

  def add_4x4
    if params[:checked].to_i == 1
      render :update do |page|
        page.show "su4x4"
        page.replace_html "su4x4", :partial => "subplot4x4"
      end
    else
      render :update do |page|
        page.hide "su4x4"
        page.replace_html "su4x4", "removed"
      end
    end
  end

  def result
    @survey = params[:survey]
    @field = params[:field]
    @plot = params[:plot]
    @anno = params[:anno]
    @inout = params[:inout]
    @priest = params[:priest]
    @cod_strato = params[:cod_stra]
    @specie = params[:specie]
    @subplot = params[:subplot]

    #se il tipo è legnose e non ci sono filtri, sul singolo plot
    if @survey == "leg" && @plot != "all" && @specie.blank?
      data = Legnose.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM legnose WHERE id_plot = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",@plot,@anno]
      if data.at(0).n.to_i == 0
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
        end
      end
      #se il tipo è legnose e non ci sono filtri, su tutti i plot
    elsif @survey == "leg" && @plot == "all" && @specie.blank?
      data = Legnose.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM legnose WHERE id_plot IN (SELECT id_plot FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY plot",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
        end
      end
    #se il tipo è leg sul plot singolo con il filtro specie
    elsif @survey == "leg" && @plot != "all" && @specie.to_i == 1
      query_part = build_group_by!(@inout,@priest,@cod_strato,@specie)
      data = Legnose.find_by_sql ["SELECT id_plot as plot,descrizione_pignatti,codice_europeo as eucode, descrizione_europea as eudesc, descrizione_pignatti as specie,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM legnose WHERE id_plot = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND legnose.deleted = false GROUP BY #{query_part}",@plot,@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_filter_leg_erb(data)
        @file = leg_erb_filter_file(@stat_list,@specie)
        render :update do |page|
          page.replace_html "stat", :partial => "filter_stats", :object => [@subplot,@inout,@priest,@cod_strato,@specie,@stat_list]
        end
      end
    #se il tipo è leg su tutti i plot con il filtro specie
    elsif @survey == "leg" && @plot == "all" && @specie.to_i == 1
      query_part = build_group_by!(@inout,@priest,@cod_strato,@specie)
      data = Legnose.find_by_sql ["SELECT id_plot as plot,descrizione_pignatti,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM legnose WHERE id_plot IN (SELECT id_plot FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND legnose.deleted = false GROUP BY plot, #{query_part}",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_filter_leg_erb(data)
        @file = leg_erb_filter_file(@stat_list,@specie)
        render :update do |page|
          page.replace_html "stat", :partial => "filter_stats", :object => [@subplot,@inout,@priest,@cod_strato,@specie,@stat_list]
        end
      end
      #se il tipo di rilevazione è erb sul signolo plot e attributo diverso da nif senza filtro
    elsif @survey == "erb" && @plot != "all" && @field != "nif" && @specie.blank?
      data = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM erbacee WHERE id_plot = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",@plot,@anno]
      if data.at(0).n.to_i == 0
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
        end
      end
      #se il tipo di rilevazione è erb sul signolo plot e attributo diverso da nif con il filtro
    elsif @survey == "erb" && @plot != "all" && @field != "nif" && @specie.to_i == 1
      query_part = build_group_by!(@inout,@priest,@cod_strato,@specie)
      data = Erbacee.find_by_sql ["SELECT id_plot as plot,descrizione_pignatti,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM erbacee WHERE  id_plot = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND erbacee.deleted = false GROUP BY #{query_part}",@plot,@anno]
      if data.at(0).n.to_i == 0
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_filter_leg_erb(data)
        @file = leg_erb_filter_file(@stat_list,@specie)
        render :update do |page|
          page.replace_html "stat", :partial => "filter_stats", :object => [@subplot,@inout,@priest,@cod_strato,@specie,@stat_list]
        end
      end
    #se il tipo di rilevazione è erb su tutti i plot con attributo diverso da nif e senza filtro
    elsif @survey == "erb" && @plot == "all" && @field != "nif" && @specie.blank?
      data = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM erbacee WHERE id_plot IN (SELECT id_plot FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY plot",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
        end
      end
    #se il tipo di rilevazione è erb su tutti i plot con attributo diverso da nif e con filtro
    elsif @survey == "erb" && @plot == "all" && @field != "nif" && @specie.to_i == 1
      query_part = build_group_by!(@inout,@priest,@cod_strato,@specie)
      data = Erbacee.find_by_sql ["SELECT id_plot as plot,descrizione_pignatti,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM erbacee WHERE id_plot IN (SELECT id_plot FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND erbacee.deleted = false GROUP BY plot,#{query_part}",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_filter_leg_erb(data)
        @file = leg_erb_filter_file(@stat_list,@specie)
        render :update do |page|
          page.replace_html "stat", :partial => "filter_stats", :object => [@subplot,@inout,@priest,@cod_strato,@specie,@stat_list]
        end
      end
     #se il tipo di rilevazione è erb su singolo plot con attributo = nif e senza filtro
    elsif @survey == "erb" && @plot != "all" && @field == "nif" && @specie.blank?
      data1 = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(numero_cespi) AS max, MIN(numero_cespi) AS min,AVG(numero_cespi) as med, STDDEV(numero_cespi) as std, COUNT(numero_cespi) as n FROM erbacee WHERE id_plot = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",@plot,@anno]
      data2 = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(numero_stoloni) AS max, MIN(numero_stoloni) AS min,AVG(numero_stoloni) as med, STDDEV(numero_stoloni) as std, COUNT(numero_stoloni) as n FROM erbacee WHERE id_plot = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",@plot,@anno]
      data3 = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(numero_getti) AS max, MIN(numero_getti) AS min,AVG(numero_getti) as med, STDDEV(numero_getti) as std, COUNT(numero_getti) as n FROM erbacee WHERE id_plot = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",@plot,@anno]
      if pop_camp_null?(data1) == true && pop_camp_null?(data2) == true && pop_camp_null?(data3) == true
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_nif(data1,data2,data3)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
        end
      end
    #se il tipo di rilevazione è erb su singolo plot con attributo = nif e con filtro
    elsif @survey == "erb" && @plot != "all" && @field == "nif" && @specie.to_i == 1
      query_part = build_group_by!(@inout,@priest,@cod_strato,@specie)
      data1 = Erbacee.find_by_sql ["SELECT id_plot as plot,descrizione_pignatti,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,MAX(numero_cespi) AS max, MIN(numero_cespi) AS min,AVG(numero_cespi) as med, STDDEV(numero_cespi) as std, COUNT(numero_cespi) as n FROM erbacee WHERE id_plot = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND erbacee.deleted = false GROUP BY plot,#{query_part} ORDER BY descrizione_pignatti",@plot,@anno]
      data2 = Erbacee.find_by_sql ["SELECT id_plot as plot,descrizione_pignatti,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,MAX(numero_stoloni) AS max, MIN(numero_stoloni) AS min,AVG(numero_stoloni) as med, STDDEV(numero_stoloni) as std, COUNT(numero_stoloni) as n FROM erbacee WHERE id_plot = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND erbacee.deleted = false GROUP BY plot,#{query_part} ORDER BY descrizione_pignatti",@plot,@anno]
      data3 = Erbacee.find_by_sql ["SELECT id_plot as plot,descrizione_pignatti,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,MAX(numero_getti) AS max, MIN(numero_getti) AS min,AVG(numero_getti) as med, STDDEV(numero_getti) as std, COUNT(numero_getti) as n FROM erbacee WHERE id_plot = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND erbacee.deleted = false GROUP BY plot,#{query_part} ORDER BY descrizione_pignatti",@plot,@anno]
      if data1.blank? && data2.blank? && data3.blank?
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_nif_filtered(data1,data2,data3)
        @file = leg_erb_filter_file(@stat_list,@specie)
        render :update do |page|
          page.replace_html "stat", :partial => "filter_stats", :object => [@subplot,@inout,@priest,@cod_strato,@specie,@stat_list]
        end
      end
    #se il tipo di rilevazione è erb su singolo plot con attributo = nif e senza filtro
    elsif @survey == "erb" && @plot == "all" && @field == "nif" && @specie.blank?
      data1 = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(numero_cespi) AS max, MIN(numero_cespi) AS min,AVG(numero_cespi) as med, STDDEV(numero_cespi) as std, COUNT(numero_cespi) as n FROM erbacee WHERE id_plot IN (SELECT id_plot FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY plot",@anno]
      data2 = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(numero_stoloni) AS max, MIN(numero_stoloni) AS min,AVG(numero_stoloni) as med, STDDEV(numero_stoloni) as std, COUNT(numero_stoloni) as n FROM erbacee WHERE id_plot IN (SELECT id_plot FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY plot",@anno]
      data3 = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(numero_getti) AS max, MIN(numero_getti) AS min,AVG(numero_getti) as med, STDDEV(numero_getti) as std, COUNT(numero_getti) as n FROM erbacee WHERE id_plot IN (SELECT id_plot FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY plot",@anno]
      if data1.blank? && data2.blank? && data3.blank?
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_nif(data1,data2,data3)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
        end
      end
    #se il tipo di rilevazione è erb su singolo plot con attributo = nif e con filtro
    elsif @survey == "erb" && @plot == "all" && @field == "nif" && @specie.to_i == 1
      query_part = build_group_by!(@inout,@priest,@cod_strato,@specie)
      data1 = Erbacee.find_by_sql ["SELECT id_plot as plot,descrizione_pignatti,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,MAX(numero_cespi) AS max, MIN(numero_cespi) AS min,AVG(numero_cespi) as med, STDDEV(numero_cespi) as std, COUNT(numero_cespi) as n FROM erbacee WHERE id_plot IN (select id_plot from plot where deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND erbacee.deleted = false GROUP BY plot,#{query_part} ORDER BY plot,descrizione_pignatti",@anno]
      data2 = Erbacee.find_by_sql ["SELECT id_plot as plot,descrizione_pignatti,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,MAX(numero_stoloni) AS max, MIN(numero_stoloni) AS min,AVG(numero_stoloni) as med, STDDEV(numero_stoloni) as std, COUNT(numero_stoloni) as n FROM erbacee WHERE id_plot IN (select id_plot from plot where deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND erbacee.deleted = false GROUP BY plot,#{query_part} ORDER BY plot,descrizione_pignatti",@anno]
      data3 = Erbacee.find_by_sql ["SELECT id_plot as plot,descrizione_pignatti,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,MAX(numero_getti) AS max, MIN(numero_getti) AS min,AVG(numero_getti) as med, STDDEV(numero_getti) as std, COUNT(numero_getti) as n FROM erbacee WHERE id_plot IN (select id_plot from plot where deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND erbacee.deleted = false GROUP BY plot,#{query_part} ORDER BY plot,descrizione_pignatti",@anno]
      if data1.blank? && data2.blank? && data3.blank?
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_nif_filtered(data1,data2,data3)
        @file = leg_erb_filter_file(@stat_list,@specie)
        render :update do |page|
          page.replace_html "stat", :partial => "filter_stats", :object => [@subplot,@inout,@priest,@cod_strato,@specie,@stat_list]
        end
      end
    #se il tipo è cops ma senza l'aggiunta di altri filtri
    elsif @survey == "cops" && @plot != "all" && @inout.blank? && @priest.blank? && @cod_strato.blank? && @specie.blank?
      data = Cops.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM cops,copertura_specifica WHERE copertura_specifica.id = copertura_specifica_id AND id_plot = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",@plot,@anno]
      if data.at(0).n.to_i == 0
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
        end
      end
    #se il tipo è cops ma senza l'aggiunta di altri filtri
    elsif @survey == "cops" && @plot == "all" && @inout.blank? && @priest.blank? && @cod_strato.blank? && @specie.blank?
      data = Cops.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM cops,copertura_specifica WHERE copertura_specifica.id = copertura_specifica_id AND id_plot IN (SELECT id_plot FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY plot",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
        end
      end
    #se è un record su un plot di tipo cops con uno o più filtri aggiunti
    elsif @survey == "cops" && @plot != "all" && (@inout.to_i == 1 || @priest.to_i == 1 || @cod_strato.to_i == 1 || @specie.to_i == 1)
      query_4x4_where,query_4x4_group = "",""
      if !@subplot.blank? && @subplot.to_i == 1
        query_4x4_where = " AND subplot IN (3,4,5,6,7,9)"
        query_4x4_group = ",subplot"
      end
      query_4x4_select = ",subplot"
      query_part = build_group_by!(@inout,@priest,@cod_strato,@specie)
      data = Cops.find_by_sql ["SELECT id_plot as plot #{query_4x4_select} ,in_out,priest,codice_strato as cod_strato,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM cops,copertura_specifica WHERE copertura_specifica.id = copertura_specifica_id AND id_plot = ? #{query_4x4_where} AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND cops.deleted = false GROUP BY #{query_part} #{query_4x4_group}",@plot,@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_filter(data)
        if @subplot.blank?
          @file = cops_filter_file(@stat_list,@inout,@priest,@cod_strato,@specie,nil)
        else
          @file = cops_filter_file(@stat_list,@inout,@priest,@cod_strato,@specie,@subplot)
        end
        render :update do |page|
          page.replace_html "stat", :partial => "filter_stats", :object => [@subplot,@inout,@priest,@cod_strato,@specie,@stat_list]
        end
      end
    #se è un record su tutti i plot di tipo cops con uno o più filtri aggiunti
    elsif @survey == "cops" && @plot == "all" && (@inout.to_i == 1 || @priest.to_i == 1 || @cod_strato.to_i == 1 || @specie.to_i == 1)
      query_4x4_where,query_4x4_group = "",""
      if !@subplot.blank? && @subplot.to_i == 1
        query_4x4_where = " AND subplot IN (3,4,5,6,7,9)"
        query_4x4_group = ",subplot"
      end
      query_4x4_select = ",subplot"
      query_part = build_group_by!(@inout,@priest,@cod_strato,@specie)
      data = Cops.find_by_sql ["SELECT id_plot as plot #{query_4x4_select} ,in_out,priest,codice_strato as cod_strato,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM cops,copertura_specifica WHERE copertura_specifica.id = copertura_specifica_id AND id_plot IN (SELECT id_plot FROM plot WHERE deleted = false) #{query_4x4_where} AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND cops.deleted = false GROUP BY #{query_part},plot #{query_4x4_group}",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_filter(data)
        if @subplot.blank?
          @file = cops_filter_file(@stat_list,@inout,@priest,@cod_strato,@specie,nil)
        else
          @file = cops_filter_file(@stat_list,@inout,@priest,@cod_strato,@specie,@subplot)
        end
        render :update do |page|
          page.replace_html "stat", :partial => "filter_stats", :object => [@inout,@priest,@cod_strato,@specie,@stat_list]
        end
      end
    #se il tipo è copl ma senza l'aggiunta di altri filtri
    elsif @survey == "copl" && @plot != "all" && @inout.blank? && @priest.blank?
      data = Copl.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM copl WHERE id_plot = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",@plot,@anno]
      if data.at(0).n.to_i == 0
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
        end
      end
    #se il tipo è copl ma senza l'aggiunta di altri filtri
    elsif @survey == "copl" && @plot == "all" && @inout.blank? && @priest.blank?
      data = Copl.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM copl WHERE id_plot IN (SELECT id_plot FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY plot",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
        end
      end
    #se è un record su un plot di tipo copl con uno o più filtri aggiunti
    elsif @survey == "copl" && @plot != "all" && (@inout.to_i == 1 || @priest.to_i == 1)
      query_part = build_group_by_copl!(@inout,@priest)
      data = Copl.find_by_sql ["SELECT id_plot as plot,in_out,priest,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM copl WHERE id_plot = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY #{query_part}",@plot,@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_filter_copl(data)
        @file = copl_filter_file(@stat_list,@inout,@priest)
        render :update do |page|
          page.replace_html "stat", :partial => "filter_stats", :object => [@subplot,@inout,@priest,@cod_strato,@specie,@stat_list]
        end
      end
    #se è un record su tutti i plot di tipo copl con uno o più filtri aggiunti
    elsif @survey == "copl" && @plot == "all" && (@inout.to_i == 1 || @priest.to_i == 1)
      query_part = build_group_by_copl!(@inout,@priest)
      data = Copl.find_by_sql ["SELECT id_plot as plot,in_out,priest,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM copl WHERE id_plot IN (SELECT id_plot FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY #{query_part},plot ",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_filter_copl(data)
        @file = copl_filter_file(@stat_list,@inout,@priest)
        render :update do |page|
          page.replace_html "stat", :partial => "filter_stats", :object => [@inout,@priest,@cod_strato,@specie,@stat_list,@file]
        end
      end
    end
  end

  private

  def pop_camp_null?(data)
    n = 0
    for i in 0..data.size-1
      n += data.at(i).n.to_i
    end
    return true if n == 0
  end


  def format_data(data)
    stat_list = Array.new
    for i in 0..data.size-1
      stat = Statistic.new
      stat.set_it!(data.at(i))
      stat_list << stat
    end
    return stat_list
  end

  def format_data_nif(data_cespi,data_stoloni,data_getti)
    stat_list = Array.new
    for i in 0..data_cespi.size-1
      stat = Statistic.new
      stat.set_nif!(data_cespi.at(i),data_stoloni.at(i),data_getti.at(i))
      stat_list << stat
    end
    return stat_list
  end

  def format_data_nif_filtered(data_cespi,data_stoloni,data_getti)
    stat_list = Array.new
    for i in 0..data_cespi.size-1
      stat = StatisticFilter.new
      stat.set_nif!(data_cespi.at(i),data_stoloni.at(i),data_getti.at(i))
      stat.set_specie_filter!(data_cespi.at(i))
      stat_list << stat
    end
    return stat_list
  end

  def format_data_filter(data)
    stat_list = Array.new
    for i in 0..data.size-1
      stat = StatisticFilter.new
      stat.set_it!(data.at(i))
      stat.set_filter!(data.at(i))
      unless (data.at(i).in_out == 2 && (data.at(i).subplot == 4 || data.at(i).subplot == 6 )) || (data.at(i).in_out == 1 && (data.at(i).subplot == 3 || data.at(i).subplot == 5 ))
        stat_list << stat
      end
    end
    return stat_list
  end

  def format_data_filter_leg_erb(data)
    stat_list = Array.new
    for i in 0..data.size-1
      stat = StatisticFilter.new
      stat.set_it!(data.at(i))
      stat.set_specie_filter!(data.at(i))
      stat_list << stat
    end
    return stat_list
  end

  def format_data_filter_copl(data)
    stat_list = Array.new
    for i in 0..data.size-1
      stat = StatisticFilter.new
      stat.set_it!(data.at(i))
      stat.set_less_filter!(data.at(i))
      stat_list << stat
    end
    return stat_list
  end

  def build_group_by!(inout,priest,cod_stra,spe)
    string = ""
    string = string + "in_out" if inout.to_i == 1 && string == ""
    string = string + "priest" if priest.to_i == 1 && string == ""
    string = string + "codice_strato" if cod_stra.to_i == 1 && string == ""
    string = string + "descrizione_pignatti" if spe.to_i == 1 && string == ""

    string = string + ",in_out" if inout.to_i == 1 && string != ""
    string = string + ",priest" if priest.to_i == 1 && string != ""
    string = string + ",codice_strato" if cod_stra.to_i == 1 && string != ""
    string = string + ",descrizione_pignatti" if spe.to_i == 1 && string != ""
    return string
  end

  def build_group_by_copl!(inout,priest)
    string = ""
    string = string + "in_out" if inout.to_i == 1 && string == ""
    string = string + "priest" if priest.to_i == 1 && string == ""
    string = string + ",in_out" if inout.to_i == 1 && string != ""
    string = string + ",priest" if priest.to_i == 1 && string != ""

    return string
  end

  def regular_file(content)
    #creo il nuovo documento
    stat_file = Spreadsheet::Workbook.new
    #aggiungo un nuovo foglio di lavoro
    sheet1 = stat_file.create_worksheet :name => 'Foglio di lavoro 1'
    #nella prima riga metto le intestazioni
    sheet1[0,0] = "Plot"
    sheet1[0,1] = "Max"
    sheet1[0,2] = "Min"
    sheet1[0,3] = "Med"
    sheet1[0,4] = "Std"
    sheet1[0,5] = "Ste"
    sheet1[0,6] = "Cov"
    sheet1[0,7] = "Note"
    #aggiungo tutti i dati
    for i in 0..content.size-1
      sheet1[i+1,0] = content.at(i).plot
      sheet1[i+1,1] = content.at(i).max
      sheet1[i+1,2] = content.at(i).min
      sheet1[i+1,3] = content.at(i).med
      sheet1[i+1,4] = content.at(i).std
      sheet1[i+1,5] = content.at(i).ste
      sheet1[i+1,6] = content.at(i).cov
      sheet1[i+1,7] = content.at(i).note
    end

    #formattazione file
    bold = Spreadsheet::Format.new :weight => :bold
    8.times do |x| sheet1.row(0).set_format(x, bold) end

    #creo la directory
    dir = "#{RAILS_ROOT}/public/Stat/"
    #imposto il nome del file
    file_name = "stats.xls"
    #imposto il full_path e la relative_path
    full_path = dir + file_name
    relative_path = "/Stat/#{file_name}"
    require 'ftools'
    File.makedirs dir
    #scrivo il file
    stat_file.write "#{RAILS_ROOT}/public/Stat/#{file_name}"
    #creo l'oggetto file
    new_stat_file = OutputFile.new
    new_stat_file.fill(file_name,full_path,relative_path,"Stats")
    return new_stat_file
  end

  def copl_filter_file(content,inout,priest)
    #creo il nuovo documento
    stat_file = Spreadsheet::Workbook.new
    #aggiungo un nuovo foglio di lavoro
    sheet1 = stat_file.create_worksheet :name => 'Foglio di lavoro 1'
    #nella prima riga metto le intestazioni
    j=0
    sheet1[0,j] = "Plot"
    if inout.to_i == 1
      j +=1
      sheet1[0,j] = "In/Out"
    end
    if priest.to_i == 1
      j +=1
      sheet1[0,j] = "Pri/Est"
    end
    j +=1
    sheet1[0,j] = "Max"
    j +=1
    sheet1[0,j] = "Min"
    j +=1
    sheet1[0,j] = "Med"
    j +=1
    sheet1[0,j] = "Std"
    j +=1
    sheet1[0,j] = "Ste"
    j +=1
    sheet1[0,j] = "Cov"
    j +=1
    sheet1[0,j] = "Note"
    #aggiungo tutti i dati
    for i in 0..content.size-1
      j = 0
      sheet1[i+1,j] = content.at(i).plot
      if inout.to_i == 1
        j +=1
        sheet1[i+1,j] = content.at(i).inout
      end
      if priest.to_i  == 1
        j +=1
        sheet1[i+1,j] = content.at(i).priest
      end
      j +=1
      sheet1[i+1,j] = content.at(i).max
      j +=1
      sheet1[i+1,j] = content.at(i).min
      j +=1
      sheet1[i+1,j] = content.at(i).med
      j +=1
      sheet1[i+1,j] = content.at(i).std
      j +=1
      sheet1[i+1,j] = content.at(i).ste
      j +=1
      sheet1[i+1,j] = content.at(i).cov
      j +=1
      sheet1[i+1,j] = content.at(i).note
    end

    #formattazione file
    bold = Spreadsheet::Format.new :weight => :bold
    10.times do |x| sheet1.row(0).set_format(x, bold) end

    #creo la directory
    dir = "#{RAILS_ROOT}/public/Stat/"
    #imposto il nome del file
    file_name = "stats.xls"
    #imposto il full_path e la relative_path
    full_path = dir + file_name
    relative_path = "/Stat/#{file_name}"
    require 'ftools'
    File.makedirs dir
    #scrivo il file
    stat_file.write "#{RAILS_ROOT}/public/Stat/#{file_name}"
    #creo l'oggetto file
    new_stat_file = OutputFile.new
    new_stat_file.fill(file_name,full_path,relative_path,"Stats")
    return new_stat_file
  end

  def cops_filter_file(content,inout,priest,cod_strato,specie,subplot)
    #creo il nuovo documento
    stat_file = Spreadsheet::Workbook.new
    #aggiungo un nuovo foglio di lavoro
    sheet1 = stat_file.create_worksheet :name => 'Foglio di lavoro 1'
    #nella prima riga metto le intestazioni
    j=0
    sheet1[0,j] = "Plot"
    if subplot.to_i == 1
      j +=1
      sheet1[0,j] = "Subplot"
    end
    if inout.to_i == 1
      j +=1
      sheet1[0,j] = "In/Out"
    end
    if priest.to_i == 1
      j +=1
      sheet1[0,j] = "Pri/Est"
    end
    if cod_strato.to_i == 1
      j +=1
      sheet1[0,j] = "Codice Strato"
    end
    if specie.to_i == 1
      j +=1
      sheet1[0,j] = "EU Code"
      j +=1
      sheet1[0,j] = "EU Desc"
      j +=1
      sheet1[0,j] = "Specie"
    end
    j +=1
    sheet1[0,j] = "Max"
    j +=1
    sheet1[0,j] = "Min"
    j +=1
    sheet1[0,j] = "Med"
    j +=1
    sheet1[0,j] = "Std"
    j +=1
    sheet1[0,j] = "Ste"
    j +=1
    sheet1[0,j] = "Cov"
    j +=1
    sheet1[0,j] = "Note"
    #aggiungo tutti i dati
    for i in 0..content.size-1
      j = 0
      sheet1[i+1,j] = content.at(i).plot
      if subplot.to_i == 1
        j +=1
        sheet1[i+1,j] = content.at(i).subplot
      end
      if inout.to_i == 1
        j +=1
        sheet1[i+1,j] = content.at(i).inout
      end
      if priest.to_i  == 1
        j +=1
        sheet1[i+1,j] = content.at(i).priest
      end
      if cod_strato.to_i  == 1
        j +=1
        sheet1[i+1,j] = content.at(i).cod_strato
      end
      if specie.to_i  == 1
        j +=1
        sheet1[i+1,j] = content.at(i).eucode
        j +=1
        sheet1[i+1,j] = content.at(i).eudesc
        j +=1
        sheet1[i+1,j] = content.at(i).specie
      end
      j +=1
      sheet1[i+1,j] = content.at(i).max
      j +=1
      sheet1[i+1,j] = content.at(i).min
      j +=1
      sheet1[i+1,j] = content.at(i).med
      j +=1
      sheet1[i+1,j] = content.at(i).std
      j +=1
      sheet1[i+1,j] = content.at(i).ste
      j +=1
      sheet1[i+1,j] = content.at(i).cov
      j +=1
      sheet1[i+1,j] = content.at(i).note
    end

    #formattazione file
    bold = Spreadsheet::Format.new :weight => :bold
    12.times do |x| sheet1.row(0).set_format(x, bold) end

    #creo la directory
    dir = "#{RAILS_ROOT}/public/Stat/"
    #imposto il nome del file
    file_name = "stats.xls"
    #imposto il full_path e la relative_path
    full_path = dir + file_name
    relative_path = "/Stat/#{file_name}"
    require 'ftools'
    File.makedirs dir
    #scrivo il file
    stat_file.write "#{RAILS_ROOT}/public/Stat/#{file_name}"
    #creo l'oggetto file
    new_stat_file = OutputFile.new
    new_stat_file.fill(file_name,full_path,relative_path,"Stats")
    return new_stat_file
  end

  def leg_erb_filter_file(content,specie)
    #creo il nuovo documento
    stat_file = Spreadsheet::Workbook.new
    #aggiungo un nuovo foglio di lavoro
    sheet1 = stat_file.create_worksheet :name => 'Foglio di lavoro 1'
    #nella prima riga metto le intestazioni
    j=0
    sheet1[0,j] = "Plot"
    if specie.to_i == 1
      j +=1
      sheet1[0,j] = "EU Code"
      j +=1
      sheet1[0,j] = "EU Desc"
      j +=1
      sheet1[0,j] = "Specie"
    end
    j +=1
    sheet1[0,j] = "Max"
    j +=1
    sheet1[0,j] = "Min"
    j +=1
    sheet1[0,j] = "Med"
    j +=1
    sheet1[0,j] = "Std"
    j +=1
    sheet1[0,j] = "Ste"
    j +=1
    sheet1[0,j] = "Cov"
    j +=1
    sheet1[0,j] = "Note"
    #aggiungo tutti i dati
    for i in 0..content.size-1
      j = 0
      sheet1[i+1,j] = content.at(i).plot
      if specie.to_i  == 1
        j +=1
        sheet1[i+1,j] = content.at(i).eucode
        j +=1
        sheet1[i+1,j] = content.at(i).eudesc
        j +=1
        sheet1[i+1,j] = content.at(i).specie
      end
      j +=1
      sheet1[i+1,j] = content.at(i).max
      j +=1
      sheet1[i+1,j] = content.at(i).min
      j +=1
      sheet1[i+1,j] = content.at(i).med
      j +=1
      sheet1[i+1,j] = content.at(i).std
      j +=1
      sheet1[i+1,j] = content.at(i).ste
      j +=1
      sheet1[i+1,j] = content.at(i).cov
      j +=1
      sheet1[i+1,j] = content.at(i).note
    end

    #formattazione file
    bold = Spreadsheet::Format.new :weight => :bold
    12.times do |x| sheet1.row(0).set_format(x, bold) end

    #creo la directory
    dir = "#{RAILS_ROOT}/public/Stat/"
    #imposto il nome del file
    file_name = "stats.xls"
    #imposto il full_path e la relative_path
    full_path = dir + file_name
    relative_path = "/Stat/#{file_name}"
    require 'ftools'
    File.makedirs dir
    #scrivo il file
    stat_file.write "#{RAILS_ROOT}/public/Stat/#{file_name}"
    #creo l'oggetto file
    new_stat_file = OutputFile.new
    new_stat_file.fill(file_name,full_path,relative_path,"Stats")
    return new_stat_file
  end

end
