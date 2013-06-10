class ProvaController < ApplicationController

  def index
   @euflora = Euflora.find(:all)

  end

private
  def format_data_filter(data,anno)
    list = Array.new
    for i in 0..data.size-1
      stat = StatisticSuFilter.new
      stat.fill_it!(data.at(i),anno)
      list << stat
    end
    return list
  end


  def format_data(data,survey,anno)
    list = Array.new
    for i in 0..data.size-1
      stat = StatisticSu.new
      stat.fill_erb(data.at(i),anno) if survey == "erb"
      stat.fill_leg(data.at(i)) if survey == "leg" || survey == "cops"
      list << stat unless stat.individui.to_i == 0 && survey != "erb" #erb aveva delle specie con individui = 0
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
      sheet1[i-1,0] = anno
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
      sheet1[0,j] == "Pri/Est"
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
        sheet1[i+1,j] == content.at(i).priest
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
