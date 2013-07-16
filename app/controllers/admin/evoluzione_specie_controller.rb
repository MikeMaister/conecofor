class Admin::EvoluzioneSpecieController < ApplicationController

  def index

  end

  def input_mask_all
    render :update do |page|
      page.show "input_mask"
      page.replace_html "input_mask","all"
      page.hide "result"
    end
  end

  def input_mask_psc
    @plot = Plot.find(:all,:conditions => "deleted = false",:order => "id_plot")
    @campagne = Campagne.find(:all,:conditions => "deleted = false",:order => "anno")
    render :update do |page|
      page.show "input_mask"
      page.replace_html "input_mask", :partial => "survey_mask", :object => [@plot,@campagne]
      page.hide "result"
    end
  end

  def survey_result
    case params[:survey]
      when "Erb"
        #cerco i risultati nella tabella erbacee
        specie = Erbacee.find_by_sql ["SELECT DISTINCT specie_id FROM erbacee WHERE temp = false AND approved = true AND deleted = false AND plot_id = ? AND campagne_id IN (select id from campagne where anno = ?) AND specie_id IS NOT NULL",params[:plot],params[:anno]]
        #carico i dati dell'evoluzione
        @evolution,@eu_evolution = get_evolution(specie)
      when "Leg"
        #cerco i risultati nella tabella legnose
        specie = Legnose.find_by_sql ["SELECT DISTINCT specie_id FROM legnose WHERE temp = false AND approved = true AND deleted = false AND plot_id = ? AND campagne_id IN (select id from campagne where anno = ?) AND specie_id IS NOT NULL",params[:plot],params[:anno]]
        #carico i dati dell'evoluzione
        @evolution,@eu_evolution = get_evolution(specie)
      when "Cops"
        #cerco i risultati nella tabella cops
        specie = Cops.find_by_sql ["SELECT DISTINCT specie_id FROM cops WHERE temp = false AND approved = true AND deleted = false AND plot_id = ? AND campagne_id IN (select id from campagne where anno = ?) AND specie_id IS NOT NULL",params[:plot],params[:anno]]
        #carico i dati dell'evoluzione
        @evolution,@eu_evolution = get_evolution(specie)
    end
    #creazione file .xls
    @file = create_xls(@evolution,@eu_evolution)
    render :update do |page|
      page.show "result"
      page.replace_html "result", :partial => "result", :object => [@evolution,@eu_evolution,@file]
    end
  end

  def download_file
    @file = OutputFile.find(params[:file])
    send_file(@file.path, :filename => "#{@file.file_name}")
  end


  private

  def create_xls(pignatti,euflora)
    #creo il nuovo documento
    stat_file = Spreadsheet::Workbook.new

    #SCHEDA PIGNATTI

    #aggiungo un nuovo foglio di lavoro
    sheet1 = stat_file.create_worksheet :name => 'Pignatti'
    #nella prima riga metto le intestazioni
    #imposto un contatore di posizione
    posizione_y = 0
    posizione_x = 0
    #scorro tutte le righe
    for i in 0..pignatti.size-1
      sheet1[posizione_y,posizione_x+1] = "Stato Attuale"
      sheet1[posizione_y+1,posizione_x+1] = "Pignatti"
      sheet1[posizione_y+2,posizione_x] = "Descrizione"
      sheet1[posizione_y+2,posizione_x+1] = pignatti.at(i).at(0).descrizione
      sheet1[posizione_y+3,posizione_x+1] = "Euflora"
      sheet1[posizione_y+4,posizione_x] = "Codice Europeo"
      sheet1[posizione_y+4,posizione_x+1] = Euflora.find(pignatti.at(i).at(0).euflora_id).codice_eu
      sheet1[posizione_y+5,posizione_x] = "Famiglia"
      sheet1[posizione_y+5,posizione_x+1] = Euflora.find(pignatti.at(i).at(0).euflora_id).famiglia
      sheet1[posizione_y+6,posizione_x] = "Descrizione"
      sheet1[posizione_y+6,posizione_x+1] = Euflora.find(pignatti.at(i).at(0).euflora_id).descrizione
      sheet1[posizione_y+7,posizione_x] = "Specie"
      sheet1[posizione_y+7,posizione_x+1] = Euflora.find(pignatti.at(i).at(0).euflora_id).specie
      #scorro gli stati
      for j in 0..pignatti.at(i).at(1).size-1
        unless pignatti.at(i).at(1).at(j).blank?
          sheet1[posizione_y,posizione_x+2] = "Stato #{pignatti.at(i).at(1).size - j}"
          sheet1[posizione_y+1,posizione_x+2] = "Pignatti"
          sheet1[posizione_y+2,posizione_x+2] = pignatti.at(i).at(1).at(j).spe_desc
          sheet1[posizione_y+3,posizione_x+2] = "Euflora"
          sheet1[posizione_y+4,posizione_x+2] = pignatti.at(i).at(1).at(j).codice_eu
          sheet1[posizione_y+5,posizione_x+2] = pignatti.at(i).at(1).at(j).eu_fam
          sheet1[posizione_y+6,posizione_x+2] = pignatti.at(i).at(1).at(j).eu_desc
          sheet1[posizione_y+7,posizione_x+2] = pignatti.at(i).at(1).at(j).eu_spe
          posizione_x += 1
        end
      end
      #posizione x torna al punto di partenza
      posizione_x = 0
      #formattazione file (deve stare qua in mezzo)
      #TODO Impostare i colori
      bold = Spreadsheet::Format.new :weight => :bold
      sheet1.row(posizione_y).default_format = bold
      sheet1.row(posizione_y+1).default_format = bold
      sheet1.column(posizione_x).default_format = bold
      sheet1.row(posizione_y+3).default_format = bold
      #salta di 3 in più delle righe impostate
      posizione_y += 10
    end

    #SCHEDA EUFLORA


    #aggiungo un nuovo foglio di lavoro
    sheet2 = stat_file.create_worksheet :name => 'Euflora'
    #nella prima riga metto le intestazioni
    #imposto un contatore di posizione
    posizione_y = 0
    posizione_x = 0
    #scorro tutte le righe
    for i in 0..euflora.size-1
      sheet2[posizione_y,posizione_x+1] = "Stato Attuale"
      sheet2[posizione_y+1,posizione_x+1] = "Euflora"
      sheet2[posizione_y+2,posizione_x] = "Codice Europeo"
      sheet2[posizione_y+2,posizione_x+1] = euflora.at(i).at(0).codice_eu
      sheet2[posizione_y+3,posizione_x] = "Famiglia"
      sheet2[posizione_y+3,posizione_x+1] = euflora.at(i).at(0).famiglia
      sheet2[posizione_y+4,posizione_x] = "Descrizione"
      sheet2[posizione_y+4,posizione_x+1] = euflora.at(i).at(0).descrizione
      sheet2[posizione_y+5,posizione_x] = "Specie"
      sheet2[posizione_y+5,posizione_x+1] = euflora.at(i).at(0).specie
      sheet2[posizione_y+6,posizione_x+1] = "Specie VS"
      sheet2[posizione_y+7,posizione_x] = "Species"
      sheet2[posizione_y+7,posizione_x+1] = SpecieVs.find(euflora.at(i).at(0).specie_vs_id).species unless euflora.at(i).at(0).specie_vs_id.blank?
      sheet2[posizione_y+8,posizione_x] = "Listspe"
      sheet2[posizione_y+8,posizione_x+1] = SpecieVs.find(euflora.at(i).at(0).specie_vs_id).listspe unless euflora.at(i).at(0).specie_vs_id.blank?
      sheet2[posizione_y+9,posizione_x] = "Descrizione"
      sheet2[posizione_y+9,posizione_x+1] = SpecieVs.find(euflora.at(i).at(0).specie_vs_id).descrizione unless euflora.at(i).at(0).specie_vs_id.blank?
      #scorro gli stati
      for j in 0..euflora.at(i).at(1).size-1
        unless euflora.at(i).at(1).at(j).blank?
          sheet2[posizione_y,posizione_x+2] = "Stato #{euflora.at(i).at(1).size - j}"
          sheet2[posizione_y+1,posizione_x+2] = "Euflora"
          sheet2[posizione_y+2,posizione_x+2] = euflora.at(i).at(1).at(j).codice_eu
          sheet2[posizione_y+3,posizione_x+2] = euflora.at(i).at(1).at(j).famiglia
          sheet2[posizione_y+4,posizione_x+2] = euflora.at(i).at(1).at(j).descrizione
          sheet2[posizione_y+5,posizione_x+2] = euflora.at(i).at(1).at(j).specie
          sheet2[posizione_y+6,posizione_x+2] = "Specie VS"
          sheet2[posizione_y+7,posizione_x+2] = euflora.at(i).at(1).at(j).vs_species
          sheet2[posizione_y+8,posizione_x+2] = euflora.at(i).at(1).at(j).vs_listspe
          sheet2[posizione_y+9,posizione_x+2] = euflora.at(i).at(1).at(j).vs_descrizione
          posizione_x += 1
        end
      end
      #posizione x torna al punto di partenza
      posizione_x = 0
      #formattazione file (deve stare qua in mezzo)
      #TODO Impostare i colori
      bold = Spreadsheet::Format.new :weight => :bold
      sheet2.row(posizione_y).default_format = bold
      sheet2.row(posizione_y+1).default_format = bold
      sheet2.column(posizione_x).default_format = bold
      sheet2.row(posizione_y+6).default_format = bold
      #salta di 9
      posizione_y += 12
    end

    #creo la directory
    dir = "#{RAILS_ROOT}/public/Evoluzione Specie Plot/"
    #imposto il nome del file
    file_name = "tracking specie.xls"
    #imposto il full_path e la relative_path
    full_path = dir + file_name
    relative_path = "/Evoluzione Specie Plot/#{file_name}"
    require 'ftools'
    File.makedirs dir
    #scrivo il file
    stat_file.write "#{RAILS_ROOT}/public/Evoluzione Specie Plot/#{file_name}"
    #creo l'oggetto file
    new_stat_file = OutputFile.new
    new_stat_file.fill_and_save(file_name,full_path,relative_path,"Tracking Specie")
    return new_stat_file
  end

  def get_evolution(data)
    #lista evoluzione completa
    evolution_list = Array.new
    #lista evoluzione euflora
    eu_evolution_list = Array.new
    #per ogni specie
    for i in 0..data.size-1
      #memorizzo gli id euflora
      eu_evolution_list << Specie.find(data.at(i).specie_id).euflora_id
      #lista tracking cambiamenti
      track = Array.new
      mod = TrackSpecie.find(:all, :conditions => ["specie_id = ?",data.at(i).specie_id], :order => "data desc")
      #per ogni modifica trovata la memorizzo nell'array track
      #a meno che non sia vuoto
      unless mod.blank?
        for j in 0..mod.size-1
          track << mod.at(j)
          #memorizzo gli id euflora
          eu_evolution_list << mod.at(j).euflora_id
        end
      end
      #lista evoluzione singola specie
      evolution = Array.new
      evolution << Specie.find(data.at(i).specie_id)
      evolution << track
      #pusho tutto nel risultato
      evolution_list << evolution
    end
    #elimino i duplicati euflora
    temp = eu_evolution_list.uniq
    #elimino gli elementi nil dall'array
    eu_evolution_list = temp.compact
    #formatto i dati euflora
    eu_evolution_list1 = get_euflora_evolution(eu_evolution_list)
    return evolution_list, eu_evolution_list1
  end

  def get_euflora_evolution(euflora_id_list)
    eu_evolution_list = Array.new
    for i in 0..euflora_id_list.size-1
      track = Array.new
      mod = TrackEuflora.find(:all,:conditions => ["euflora_id = ?",euflora_id_list.at(i)],:order => "data desc")
      #per ogni modifica trovata la memorizzo nell'array track
      #a meno che non sia vuoto
      unless mod.blank?
        for j in 0..mod.size-1
          track << mod.at(j)
        end
      end
      evolution = Array.new
      evolution << Euflora.find(euflora_id_list.at(i))
      evolution << track
      eu_evolution_list << evolution
    end
    return eu_evolution_list
  end

end
