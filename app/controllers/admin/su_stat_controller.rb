class Admin::SuStatController < ApplicationController

  def index
    @plot = Plot.find(:all,:conditions => "deleted = false",:order => "id_plot")
    @anno = Campagne.find_by_sql "SELECT DISTINCT(anno) FROM campagne WHERE deleted = false ORDER BY anno"
  end

  def show_filter
    if params[:selected_survey] == "cops"
      render :update do |page|
        page.show "filter"
        page.replace_html "filter", :partial => "filter"
      end
    else
      render :update do |page|
        page.hide "filter"
        page.replace_html "filter", ""
      end
    end
  end

  def result
    @survey = params[:survey]
    @anno = params[:anno]
    @plot = params[:plot]
    @inout = params[:inout]
    @priest = params[:priest]
    @cod_strato = params[:cod_strato]

    if @survey == "erb" && @plot == "all"
      data = Erbacee.find_by_sql ["select id_plot as plot,subplot,codice_eu as eucode,euflora.descrizione as eudesc,specie.descrizione as specie,specie_id,sum(copertura) as copertura,sum(numero_cespi) as n_c,sum(numero_stoloni) as n_s,sum(numero_getti) as n_g from erbacee,specie,euflora where euflora_id = euflora.id and specie_id = specie.id and erbacee.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and plot_id in (select id from plot where deleted = false) group by plot,subplot,specie having specie_id",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "su_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data,@survey,@anno)
        @file = regular_file(@stat_list,@anno)
        render :update do |page|
          page.replace_html "su_stat",:partial => "subplot_stats", :object => [@anno,@stat_list,@file]
        end
      end
    elsif @survey == "erb" && @plot != "all"
      data = Erbacee.find_by_sql ["select id_plot as plot,subplot,codice_eu as eucode,euflora.descrizione as eudesc,specie.descrizione as specie,specie_id,sum(copertura) as copertura,sum(numero_cespi) as n_c,sum(numero_stoloni) as n_s,sum(numero_getti) as n_g from erbacee,specie,euflora where euflora_id = euflora.id and specie_id = specie.id and erbacee.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and plot_id = ? group by plot,subplot,specie having specie_id",@anno,@plot]
      if data.blank?
        render :update do |page|
          page.replace_html "su_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data,@survey,@anno)
        @file = regular_file(@stat_list,@anno)
        render :update do |page|
          page.replace_html "su_stat",:partial => "subplot_stats", :object => [@anno,@stat_list,@file]
        end
      end
    elsif @survey == "leg" && @plot == "all"
      data = Legnose.find_by_sql ["select id_plot as plot,subplot,codice_eu as eucode,euflora.descrizione as eudesc,specie.descrizione as specie,specie_id,sum(copertura) as copertura,count(specie_id) as individui from legnose,specie,euflora where euflora_id = euflora.id and specie_id = specie.id and legnose.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and plot_id in (select id from plot where deleted = false) group by plot,subplot,specie having specie_id",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "su_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data,@survey,@anno)
        @file = regular_file(@stat_list,@anno)
        render :update do |page|
          page.replace_html "su_stat",:partial => "subplot_stats", :object => [@anno,@stat_list,@file]
        end
      end
    elsif @survey == "leg" && @plot != "all"
      data = Legnose.find_by_sql ["select id_plot as plot,subplot,codice_eu as eucode,euflora.descrizione as eudesc,specie.descrizione as specie,specie_id,sum(copertura) as copertura,count(specie_id) as individui from legnose,specie,euflora where euflora_id = euflora.id and specie_id = specie.id and legnose.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and plot_id = ? group by plot,subplot,specie having specie_id",@anno,@plot]
      if data.blank?
        render :update do |page|
          page.replace_html "su_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data,@survey,@anno)
        @file = regular_file(@stat_list,@anno)
        render :update do |page|
          page.replace_html "su_stat",:partial => "subplot_stats", :object => [@anno,@stat_list,@file]
        end
      end
    elsif @survey == "cops" && @plot == "all" && (@inout.blank? && @priest.blank? && @cod_strato.blank?)
      data = Cops.find_by_sql ["select id_plot as plot,subplot,codice_eu as eucode,euflora.descrizione as eudesc,specie.descrizione as specie,specie_id,sum(value) as copertura,count(specie_id) as individui from cops,specie,euflora,copertura_specifica where copertura_specifica_id = copertura_specifica.id and euflora_id = euflora.id and specie_id = specie.id and cops.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and plot_id in (select id from plot where deleted = false) group by plot,subplot,specie having specie_id",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "su_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data,@survey,@anno)
        @file = regular_file(@stat_list,@anno)
        render :update do |page|
          page.replace_html "su_stat",:partial => "subplot_stats", :object => [@anno,@stat_list,@file]
        end
      end
    elsif @survey == "cops" && @plot != "all" && (@inout.blank? && @priest.blank? && @cod_strato.blank?)
      data = Cops.find_by_sql ["select id_plot as plot,subplot,codice_eu as eucode,euflora.descrizione as eudesc,specie.descrizione as specie,specie_id,sum(value) as copertura,count(specie_id) as individui from cops,specie,euflora,copertura_specifica where copertura_specifica_id = copertura_specifica.id and euflora_id = euflora.id and specie_id = specie.id and cops.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and plot_id = ? group by plot,subplot,specie having specie_id",@anno,@plot]
      if data.blank?
        render :update do |page|
          page.replace_html "su_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data,@survey,@anno)
        @file = regular_file(@stat_list,@anno)
        render :update do |page|
          page.replace_html "su_stat",:partial => "subplot_stats", :object => [@anno,@stat_list,@file]
        end
      end
    elsif @survey == "cops" && @plot == "all" && (@inout.to_i == 1 || @priest.to_i == 1 || @cod_strato.to_i == 1)
      query_part = build_group_by!(@inout,@priest,@cod_strato)
      data = Cops.find_by_sql ["select id_plot as plot,subplot,in_out,priest,codice_strato,codice_eu as eucode,euflora.descrizione as eudesc,specie.descrizione as specie,specie_id,sum(value) as copertura, count(specie_id) as individui from cops,specie,euflora,copertura_specifica where copertura_specifica_id = copertura_specifica.id and euflora_id = euflora.id and specie_id = specie.id and cops.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and plot_id in (select id from plot where deleted = false) group by plot,subplot #{query_part},specie  having specie_id",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "su_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_filter(data,@anno)
        @file = filter_file(@stat_list,@inout,@priest,@cod_strato,@anno)
        render :update do |page|
          page.replace_html "su_stat", :partial => "su_stats_filtered", :object => [@inout,@priest,@cod_strato,@stat_list,@file,@anno]
        end
      end
    elsif @survey == "cops" && @plot != "all" && (@inout.to_i == 1 || @priest.to_i == 1 || @cod_strato.to_i == 1)
      query_part = build_group_by!(@inout,@priest,@cod_strato)
      data = Cops.find_by_sql ["select id_plot as plot,subplot,in_out,priest,codice_strato,codice_eu as eucode,euflora.descrizione as eudesc,specie.descrizione as specie,specie_id,sum(value) as copertura, count(specie_id) as individui from cops,specie,euflora,copertura_specifica where copertura_specifica_id = copertura_specifica.id and euflora_id = euflora.id and specie_id = specie.id and cops.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and plot_id = ? group by plot,subplot #{query_part},specie  having specie_id",@anno,@plot]
      if data.blank?
        render :update do |page|
          page.replace_html "su_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_filter(data,@anno)
        @file = filter_file(@stat_list,@inout,@priest,@cod_strato,@anno)
        render :update do |page|
          page.replace_html "su_stat", :partial => "su_stats_filtered", :object => [@inout,@priest,@cod_strato,@stat_list,@file,@anno]
        end
      end
    end

  end

  private

  def format_data(data,survey,anno)
    list = Array.new
    for i in 0..data.size-1
      stat = StatisticSu.new
      stat.fill_erb(data.at(i),anno) if survey == "erb"
      stat.fill_leg(data.at(i)) if survey == "leg"
      stat.fill_cops(data.at(i)) if survey == "cops"
      list << stat #unless data.individui.to_i == 0 && survey != "erb" #erb aveva delle specie con individui = 0
    end
    return list
  end



  def format_data_filter(data,anno)
    list = Array.new
    for i in 0..data.size-1
      stat = StatisticSuFilter.new
      stat.fill_it!(data.at(i),anno)
      list << stat
    end
    return list
  end

  def regular_file(content,anno)
    #creo il nuovo documento
    stat_file = Spreadsheet::Workbook.new
    #aggiungo un nuovo foglio di lavoro
    sheet1 = stat_file.create_worksheet :name => 'Foglio di lavoro 1'
    #nella prima riga metto le intestazioni
    sheet1[0,0] = "Anno"
    sheet1[0,1] = "Plot"
    sheet1[0,2] = "Subplot"
    sheet1[0,3] = "Eucode"
    sheet1[0,4] = "Eudesc"
    sheet1[0,5] = "Specie"
    sheet1[0,6] = "Copertura"
    sheet1[0,7] = "Individui"
    #aggiungo tutti i dati
    for i in 0..content.size-1
      sheet1[i+1,0] = anno
      sheet1[i+1,1] = content.at(i).plot
      sheet1[i+1,2] = content.at(i).subplot
      sheet1[i+1,3] = content.at(i).eucode
      sheet1[i+1,4] = content.at(i).eudesc
      sheet1[i+1,5] = content.at(i).specie
      sheet1[i+1,6] = content.at(i).copertura
      sheet1[i+1,7] = content.at(i).individui
    end

    #formattazione file
    bold = Spreadsheet::Format.new :weight => :bold
    8.times do |x| sheet1.row(0).set_format(x, bold) end

    #creo la directory
    dir = "#{RAILS_ROOT}/public/Stat Su/"
    #imposto il nome del file
    file_name = "stat_su.xls"
    #imposto il full_path e la relative_path
    full_path = dir + file_name
    relative_path = "/Stat Su/#{file_name}"
    require 'ftools'
    File.makedirs dir
    #scrivo il file
    stat_file.write "#{RAILS_ROOT}/public/Stat Su/#{file_name}"
    #creo l'oggetto file
    new_stat_file = OutputFile.new
    new_stat_file.fill(file_name,full_path,relative_path,"Stats Su")
    return new_stat_file
  end

  def build_group_by!(inout,priest,cod_stra)
    string = ""
    string = string + ",in_out" if inout.to_i == 1
    string = string + ",priest" if priest.to_i == 1
    string = string + ",codice_strato" if cod_stra.to_i == 1
    return string
  end

  def filter_file(content,inout,priest,cod_strato,anno)
    #creo il nuovo documento
    stat_file = Spreadsheet::Workbook.new
    #aggiungo un nuovo foglio di lavoro
    sheet1 = stat_file.create_worksheet :name => 'Foglio di lavoro 1'
    #nella prima riga metto le intestazioni
    j = 0
    sheet1[0,j] = "Anno"
    j += 1
    sheet1[0,j] = "Plot"
    j += 1
    sheet1[0,j] = "Subplot"
    if inout.to_i == 1
      j += 1
      sheet1[0,j] = "In/Out"
    end
    if priest.to_i == 1
      j += 1
      sheet1[0,j] = "Pri/Est"
    end
    if cod_strato.to_i == 1
      j += 1
      sheet1[0,j] = "Codice Strato"
    end
    j += 1
    sheet1[0,j] = "Eucode"
    j += 1
    sheet1[0,j] = "Eudesc"
    j += 1
    sheet1[0,j] = "Specie"
    j += 1
    sheet1[0,j] = "Copertura"
    j += 1
    sheet1[0,j] = "Individui"
    #aggiungo tutti i dati
    for i in 0..content.size-1
      j = 0
      sheet1[i+1,j] = anno
      j += 1
      sheet1[i+1,j] = content.at(i).plot
      j += 1
      sheet1[i+1,j] = content.at(i).subplot
      if inout.to_i == 1
        j += 1
        sheet1[i+1,j] = content.at(i).inout
      end
      if priest.to_i == 1
        j += 1
        sheet1[i+1,j] = content.at(i).priest
      end
      if cod_strato.to_i == 1
        j += 1
        sheet1[i+1,j] = content.at(i).cod_strato
      end
      j += 1
      sheet1[i+1,j] = content.at(i).eucode
      j += 1
      sheet1[i+1,j] = content.at(i).eudesc
      j += 1
      sheet1[i+1,j] = content.at(i).specie
      j += 1
      sheet1[i+1,j] = content.at(i).copertura
      j += 1
      sheet1[i+1,j] = content.at(i).individui
    end

    #formattazione file
    bold = Spreadsheet::Format.new :weight => :bold
    12.times do |x| sheet1.row(0).set_format(x, bold) end


    #creo la directory
    dir = "#{RAILS_ROOT}/public/Stat Specie/"
    #imposto il nome del file
    file_name = "stat_specie.xls"
    #imposto il full_path e la relative_path
    full_path = dir + file_name
    relative_path = "/Stat Specie/#{file_name}"
    require 'ftools'
    File.makedirs dir
    #scrivo il file
    stat_file.write "#{RAILS_ROOT}/public/Stat Specie/#{file_name}"
    #creo l'oggetto file
    new_stat_file = OutputFile.new
    new_stat_file.fill(file_name,full_path,relative_path,"Stats")
    return new_stat_file
  end

end
