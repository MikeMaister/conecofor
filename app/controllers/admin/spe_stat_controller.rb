class Admin::SpeStatController < ApplicationController

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
      data = Erbacee.find_by_sql ["select id_plot as plot,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,sum(numero_cespi) as n_c,sum(numero_stoloni) as n_s,sum(numero_getti) as n_g from erbacee where erbacee.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and id_plot in (select id_plot from plot where deleted = false) and descrizione_pignatti is not null group by plot,specie",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "spe_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data,@survey)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "spe_stat",:partial => "species_stats", :object => [@stat_list,@file]
        end
      end
    elsif @survey == "erb" && @plot != "all"
      data = Erbacee.find_by_sql ["select id_plot as plot,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,sum(numero_cespi) as n_c,sum(numero_stoloni) as n_s,sum(numero_getti) as n_g from erbacee where erbacee.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and id_plot = ? and descrizione_pignatti is not null group by plot,specie",@anno,@plot]
      if data.blank?
        render :update do |page|
          page.replace_html "spe_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data,@survey)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "spe_stat", :partial => "species_stats", :object => [@stat_list,@file]
        end
      end
    elsif @survey == "leg" && @plot == "all"
      data = Legnose.find_by_sql ["select id_plot as plot,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie, count(descrizione_pignatti) as individui from legnose where legnose.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and id_plot in (select id_plot from plot where deleted = false) and descrizione_pignatti is not null group by plot,specie",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "spe_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data,@survey)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "spe_stat", :partial => "species_stats", :object => [@stat_list,@file]
        end
      end
    elsif @survey == "leg" && @plot != "all"
      data = Legnose.find_by_sql ["select id_plot as plot,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie, count(descrizione_pignatti) as individui from legnose where legnose.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and id_plot = ? and descrizione_pignatti is not null group by plot,specie",@anno,@plot]
      if data.blank?
        render :update do |page|
          page.replace_html "spe_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data,@survey)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "spe_stat", :partial => "species_stats", :object => [@stat_list,@file]
        end
      end
    elsif @survey == "erbleg" && @plot == "all"
      erb = Erbacee.find_by_sql ["select id_plot as plot,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,sum(numero_cespi) as n_c,sum(numero_stoloni) as n_s,sum(numero_getti) as n_g from erbacee where erbacee.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and id_plot in (select id_plot from plot where deleted = false) and descrizione_pignatti is not null group by plot,specie",@anno]
      leg = Legnose.find_by_sql ["select id_plot as plot,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,count(descrizione_pignatti) as individui from legnose where legnose.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and id_plot in (select id_plot from plot where deleted = false) and descrizione_pignatti is not null group by plot,specie",@anno]
      if erb.blank? && leg.blank?
        render :update do |page|
          page.replace_html "spe_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        erb_list = format_data(erb,"erb")
        leg_list = format_data(leg,"leg")
        @stat_list = combine_data(erb_list,leg_list)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "spe_stat", :partial => "species_stats", :object => [@stat_list,@file]
        end
      end
    elsif @survey == "erbleg" && @plot != "all"
      erb = Erbacee.find_by_sql ["select id_plot as plot,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie,sum(numero_cespi) as n_c,sum(numero_stoloni) as n_s,sum(numero_getti) as n_g from erbacee where erbacee.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and id_plot = ? and descrizione_pignatti is not null group by plot,specie",@anno,@plot]
      leg = Legnose.find_by_sql ["select id_plot as plot,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie, count(descrizione_pignatti) as individui from legnose where legnose.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and id_plot = ? and descrizione_pignatti is not null group by plot,specie",@anno,@plot]
      if erb.blank? && leg.blank?
        render :update do |page|
          page.replace_html "spe_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        erb_list = format_data(erb,"erb")
        leg_list = format_data(leg,"leg")
        @stat_list = combine_data(erb_list,leg_list)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "spe_stat", :partial => "species_stats", :object => [@stat_list,@file]
        end
      end
    elsif @survey == "cops" && @plot == "all" && (@inout.blank? && @priest.blank? && @cod_strato.blank?)
      data = Cops.find_by_sql ["select id_plot as plot,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie, count(descrizione_pignatti) as individui from cops where cops.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and id_plot in (select id_plot from plot where deleted = false) and descrizione_pignatti is not null group by plot,specie",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "spe_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data,@survey)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "spe_stat", :partial => "species_stats", :object => [@stat_list,@file]
        end
      end
    elsif @survey == "cops" && @plot != "all" && (@inout.blank? && @priest.blank? && @cod_strato.blank?)
      data = Cops.find_by_sql ["select id_plot as plot,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie, count(descrizione_pignatti) as individui from cops where cops.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and id_plot = ? and descrizione_pignatti is not null group by plot,specie",@anno,@plot]
      if data.blank?
        render :update do |page|
          page.replace_html "spe_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data(data,@survey)
        @file = regular_file(@stat_list)
        render :update do |page|
          page.replace_html "spe_stat", :partial => "species_stats", :object => [@stat_list,@file]
        end
      end
    elsif @survey == "cops" && @plot == "all" && (@inout.to_i == 1 || @priest.to_i == 1 || @cod_strato.to_i == 1)
      query_part = build_group_by!(@inout,@priest,@cod_strato)
      data = Cops.find_by_sql ["select id_plot as plot,in_out,priest,codice_strato,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie, count(descrizione_pignatti) as individui from cops where cops.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and id_plot in (select id_plot from plot where deleted = false) and descrizione_pignatti is not null group by plot #{query_part},specie",@anno]
      if data.blank?
        render :update do |page|
          page.replace_html "spe_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_filter(data)
        @file = filter_file(@stat_list,@inout,@priest,@cod_strato)
        render :update do |page|
          page.replace_html "spe_stat", :partial => "specie_stats_filtered", :object => [@inout,@priest,@cod_strato,@stat_list,@file]
        end
      end
    elsif @survey == "cops" && @plot != "all" && (@inout.to_i == 1 || @priest.to_i == 1 || @cod_strato.to_i == 1)
      query_part = build_group_by!(@inout,@priest,@cod_strato)
      data = Cops.find_by_sql ["select id_plot as plot,in_out,priest,codice_strato,codice_europeo as eucode,descrizione_europea as eudesc,descrizione_pignatti as specie, count(descrizione_pignatti) as individui from cops where cops.deleted = false and temp = false and approved = true and campagne_id IN (select id from campagne where anno = ?) and id_plot = ? and descrizione_pignatti is not null group by plot #{query_part},specie",@anno,@plot]
      if data.blank?
        render :update do |page|
          page.replace_html "spe_stat", "Nessun dato presente su cui effettuare la statistica"
        end
      else
        @stat_list = format_data_filter(data)
        @file = filter_file(@stat_list,@inout,@priest,@cod_strato)
        render :update do |page|
          page.replace_html "spe_stat", :partial => "specie_stats_filtered", :object => [@inout,@priest,@cod_strato,@stat_list,@file]
        end
      end
    end
  end

  private

  def format_data(data,survey)
    list = Array.new
    for i in 0..data.size-1
      stat = StatisticSpecie.new
      stat.fill_erb(data.at(i)) if survey == "erb"
      stat.fill_leg(data.at(i)) if survey == "leg" || survey == "cops"
      list << stat #unless data.individui.to_i == 0 && survey != "erb" #erb aveva delle specie con individui = 0
    end
    return list
  end

  def format_data_filter(data)
    list = Array.new
    for i in 0..data.size-1
      stat = StatisticSpecieFilter.new
      stat.fill_it!(data.at(i))
      list << stat
    end
    return list
  end

  def regular_file(content)
    #creo il nuovo documento
    stat_file = Spreadsheet::Workbook.new
    #aggiungo un nuovo foglio di lavoro
    sheet1 = stat_file.create_worksheet :name => 'Foglio di lavoro 1'
    #nella prima riga metto le intestazioni
    sheet1[0,0] = "Plot"
    sheet1[0,1] = "Eucode"
    sheet1[0,2] = "Eudesc"
    sheet1[0,3] = "Specie"
    sheet1[0,4] = "Individui"
    #aggiungo tutti i dati
    for i in 0..content.size-1
      sheet1[i+1,0] = content.at(i).plot
      sheet1[i+1,1] = content.at(i).eucode
      sheet1[i+1,2] = content.at(i).eudesc
      sheet1[i+1,3] = content.at(i).specie
      sheet1[i+1,4] = content.at(i).individui
    end

    #formattazione file
    bold = Spreadsheet::Format.new :weight => :bold
    5.times do |x| sheet1.row(0).set_format(x, bold) end

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

  def combine_data(erb_data,leg_data)
    if erb_data.blank?
      list = leg_data
    elsif leg_data.blank?
      list = erb_data
    else
      #copio il contenuto di erb nella lista finale
      #caricando così le specie iniziali già suddivide
      list = erb_data
      #scorro la lista leg
      for i in 0..leg_data.size-1
        #scorro la lista erb
        for j in 0..erb_data.size-1
          #se il plot(i),specie(i) di leg è già presente in erb e di conseguenza in list
          if leg_data.at(i).plot == erb_data.at(j).plot && leg_data.at(i).specie == erb_data.at(j).specie
            #aumento il numero degli individui di list
            list.at(j).individui = list.at(j).individui.to_i + leg_data.at(i).individui.to_i
            presente = true
            break
            #se è già presente
          else
            presente = false
          end
        end
        #aggiungo il nuovo plot,specie a list se non è stato trovato già in erb -> list
        list << leg_data.at(i) if presente == false
      end
    end
    return list
  end

  def build_group_by!(inout,priest,cod_stra)
    string = ""
    string = string + ",in_out" if inout.to_i == 1
    string = string + ",priest" if priest.to_i == 1
    string = string + ",codice_strato" if cod_stra.to_i == 1
    return string
  end

  def filter_file(content,inout,priest,cod_strato)
    #creo il nuovo documento
    stat_file = Spreadsheet::Workbook.new
    #aggiungo un nuovo foglio di lavoro
    sheet1 = stat_file.create_worksheet :name => 'Foglio di lavoro 1'
    #nella prima riga metto le intestazioni
    j = 0
    sheet1[0,j] = "Plot"
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
    sheet1[0,j] = "Individui"
    #aggiungo tutti i dati
    for i in 0..content.size-1
      j = 0
      sheet1[i+1,j] = content.at(i).plot
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
      sheet1[i+1,j] = content.at(i).individui
    end

    #formattazione file
    bold = Spreadsheet::Format.new :weight => :bold
    5.times do |x| sheet1.row(0).set_format(x, bold) end

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
