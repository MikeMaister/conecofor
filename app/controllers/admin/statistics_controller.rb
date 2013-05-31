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

    if @survey == "leg" && @plot != "all"
      data = Legnose.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM legnose WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",@plot,@anno]
      @stat_list = format_data(data)
      @file = regular_file(@stat_list)
      render :update do |page|
        page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
      end
    elsif @survey == "leg" && @plot == "all"
      data = Legnose.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM legnose WHERE plot_id IN (SELECT id FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY plot",@anno]
      @stat_list = format_data(data)
      @file = regular_file(@stat_list)
      render :update do |page|
        page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
      end
    elsif @survey == "erb" && @plot != "all" && @field != "nif"
      data = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",@plot,@anno]
      @stat_list = format_data(data)
      @file = regular_file(@stat_list)
      render :update do |page|
        page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
      end
    elsif @survey == "erb" && @plot == "all" && @field != "nif"
      data = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM erbacee WHERE plot_id IN (SELECT id FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY plot",@anno]
      @stat_list = format_data(data)
      @file = regular_file(@stat_list)
      render :update do |page|
        page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
      end
    elsif @survey == "erb" && @plot != "all" && @field == "nif"
      data1 = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(numero_cespi) AS max, MIN(numero_cespi) AS min,AVG(numero_cespi) as med, STDDEV(numero_cespi) as std, COUNT(numero_cespi) as n FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",@plot,@anno]
      data2 = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(numero_stoloni) AS max, MIN(numero_stoloni) AS min,AVG(numero_stoloni) as med, STDDEV(numero_stoloni) as std, COUNT(numero_stoloni) as n FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",@plot,@anno]
      data3 = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(numero_getti) AS max, MIN(numero_getti) AS min,AVG(numero_getti) as med, STDDEV(numero_getti) as std, COUNT(numero_getti) as n FROM erbacee WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",@plot,@anno]
      @stat_list = format_data_nif(data1,data2,data3)
      @file = regular_file(@stat_list)
      render :update do |page|
        page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
      end
    elsif @survey == "erb" && @plot == "all" && @field == "nif"
      data1 = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(numero_cespi) AS max, MIN(numero_cespi) AS min,AVG(numero_cespi) as med, STDDEV(numero_cespi) as std, COUNT(numero_cespi) as n FROM erbacee WHERE plot_id IN (SELECT id FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY plot",@anno]
      data2 = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(numero_stoloni) AS max, MIN(numero_stoloni) AS min,AVG(numero_stoloni) as med, STDDEV(numero_stoloni) as std, COUNT(numero_stoloni) as n FROM erbacee WHERE plot_id IN (SELECT id FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY plot",@anno]
      data3 = Erbacee.find_by_sql ["SELECT id_plot as plot,MAX(numero_getti) AS max, MIN(numero_getti) AS min,AVG(numero_getti) as med, STDDEV(numero_getti) as std, COUNT(numero_getti) as n FROM erbacee WHERE plot_id IN (SELECT id FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY plot",@anno]
      @stat_list = format_data_nif(data1,data2,data3)
      @file = regular_file(@stat_list)
      render :update do |page|
        page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
      end
    #se il tipo è cops ma senza l'aggiunta di altri filtri
    elsif @survey == "cops" && @plot != "all" && @inout.blank? && @priest.blank? && @cod_strato.blank? && @specie.blank?
      data = Cops.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM cops,copertura_specifica WHERE copertura_specifica.id = copertura_specifica_id AND plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",@plot,@anno]
      @stat_list = format_data(data)
      @file = regular_file(@stat_list)
      render :update do |page|
        page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
      end
    #se il tipo è cops ma senza l'aggiunta di altri filtri
    elsif @survey == "cops" && @plot == "all" && @inout.blank? && @priest.blank? && @cod_strato.blank? && @specie.blank?
      data = Cops.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM cops,copertura_specifica WHERE copertura_specifica.id = copertura_specifica_id AND plot_id IN (SELECT id FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY plot",@anno]
      @stat_list = format_data(data)
      @file = regular_file(@stat_list)
      render :update do |page|
        page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
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
      data = Cops.find_by_sql ["SELECT id_plot as plot #{query_4x4_select} ,in_out,priest,codice_strato as cod_strato,descrizione as specie,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM cops,copertura_specifica,specie WHERE specie_id = specie.id AND copertura_specifica.id = copertura_specifica_id AND plot_id = ? #{query_4x4_where} AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND cops.deleted = false GROUP BY #{query_part} #{query_4x4_group}",@plot,@anno]
      @stat_list = format_data_filter(data)
      render :update do |page|
        page.replace_html "stat", :partial => "filter_stats", :object => [@subplot,@inout,@priest,@cod_strato,@specie,@stat_list]
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
      data = Cops.find_by_sql ["SELECT id_plot as plot #{query_4x4_select} ,in_out,priest,codice_strato as cod_strato,descrizione as specie,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM cops,copertura_specifica,specie WHERE specie_id = specie.id AND copertura_specifica.id = copertura_specifica_id AND plot_id IN (SELECT id FROM plot WHERE deleted = false) #{query_4x4_where} AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND cops.deleted = false GROUP BY #{query_part},plot #{query_4x4_group}",@anno]
      @stat_list = format_data_filter(data)
      render :update do |page|
        page.replace_html "stat", :partial => "filter_stats", :object => [@inout,@priest,@cod_strato,@specie,@stat_list]
      end
    #se il tipo è copl ma senza l'aggiunta di altri filtri
    elsif @survey == "copl" && @plot != "all" && @inout.blank? && @priest.blank?
      data = Copl.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM copl WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false",@plot,@anno]
      @stat_list = format_data(data)
      @file = regular_file(@stat_list)
      render :update do |page|
        page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
      end
    #se il tipo è copl ma senza l'aggiunta di altri filtri
    elsif @survey == "copl" && @plot == "all" && @inout.blank? && @priest.blank?
      data = Copl.find_by_sql ["SELECT id_plot as plot,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM copl WHERE plot_id IN (SELECT id FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY plot",@anno]
      @stat_list = format_data(data)
      @file = regular_file(@stat_list)
      render :update do |page|
        page.replace_html "stat", :partial => "simple_stats", :object => [@stat_list,@file]
      end
    #se è un record su un plot di tipo copl con uno o più filtri aggiunti
    elsif @survey == "copl" && @plot != "all" && (@inout.to_i == 1 || @priest.to_i == 1)
      query_part = build_group_by_copl!(@inout,@priest)
      data = Copl.find_by_sql ["SELECT id_plot as plot,in_out,priest,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM copl WHERE plot_id = ? AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY #{query_part}",@plot,@anno]
      @stat_list = format_data_filter_copl(data)
      render :update do |page|
        page.replace_html "stat", :partial => "filter_stats", :object => [@subplot,@inout,@priest,@cod_strato,@specie,@stat_list]
      end
    #se è un record su tutti i plot di tipo copl con uno o più filtri aggiunti
    elsif @survey == "copl" && @plot == "all" && (@inout.to_i == 1 || @priest.to_i == 1)
      query_part = build_group_by_copl!(@inout,@priest)
      data = Copl.find_by_sql ["SELECT id_plot as plot,in_out,priest,MAX(#{@field}) AS max, MIN(#{@field}) AS min,AVG(#{@field}) as med, STDDEV(#{@field}) as std, COUNT(#{@field}) as n FROM copl WHERE plot_id IN (SELECT id FROM plot WHERE deleted = false) AND campagne_id IN (SELECT id FROM campagne WHERE anno = ? AND deleted = false) AND temp = false AND approved = true AND deleted = false GROUP BY #{query_part},plot ",@anno]
      @stat_list = format_data_filter_copl(data)
      render :update do |page|
        page.replace_html "stat", :partial => "filter_stats", :object => [@inout,@priest,@cod_strato,@specie,@stat_list]
      end
    end
  end



  private

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
    string = string + "specie_id" if spe.to_i == 1 && string == ""

    string = string + ",in_out" if inout.to_i == 1 && string != ""
    string = string + ",priest" if priest.to_i == 1 && string != ""
    string = string + ",codice_strato" if cod_stra.to_i == 1 && string != ""
    string = string + ",specie_id" if spe.to_i == 1 && string != ""
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


end
