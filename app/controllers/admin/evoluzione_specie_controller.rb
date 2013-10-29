class Admin::EvoluzioneSpecieController < ApplicationController

  def index

  end

  def input_mask_all
    render :update do |page|
      page.show "input_mask"
      page.replace_html "input_mask", :partial => "complete_mask"
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

  def create_complete_xls
    #carico tutte le specie pignatti
    pignatti = Specie.find(:all,:conditions => "deleted = false")
    #prendo tutti i dati evoluzione per pignatti
    evolution = get_complete_evolution(pignatti,"pignatti")
    #carico tutte le specie euflora
    euflora = Euflora.find(:all,:conditions => "deleted = false")
    #prendo tutti i dati evoluzione per euflora
    eu_evolution = get_complete_evolution(euflora,"euflora")
    #creo il file pignatti
    @file = create_com_xls(evolution,eu_evolution)
    render :update do |page|
      page.show "result"
      page.replace_html "result", :partial => "complete_result", :object => @file
    end
  end


  private

  def get_complete_evolution(data,data_kind)
    #lista evoluzione completa
    evolution_list = Array.new
    #per ogni specie
    for i in 0..data.size-1
      #lista tracking cambiamenti
      track = Array.new
      mod = TrackSpecie.find(:all, :conditions => ["specie_id = ?",data.at(i).id], :order => "data desc") if data_kind == "pignatti"
      mod = TrackEuflora.find(:all,:conditions => ["euflora_id = ?",data.at(i).id],:order => "data desc") if data_kind == "euflora"
      #per ogni modifica trovata la memorizzo nell'array track
      #a meno che non sia vuoto
      unless mod.blank?
        for j in 0..mod.size-1
          track << mod.at(j)
        end
      end
      #prendo solamente le speci che hanno subito modifiche VELOCIZZA LA PROCEDURA FIX 29/10/2013
      unless track.blank?
        #lista evoluzione singola specie
        evolution = Array.new
        evolution << data.at(i)
        evolution << track
        #pusho tutto nel risultato
        evolution_list << evolution
      end
    end
    return evolution_list
  end

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
      sheet1[posizione_y+4,posizione_x+1] = Euflora.find(pignatti.at(i).at(0).euflora_id).codice_eu unless pignatti.at(i).at(0).euflora_id.blank?
      sheet1[posizione_y+5,posizione_x] = "Famiglia"
      sheet1[posizione_y+5,posizione_x+1] = Euflora.find(pignatti.at(i).at(0).euflora_id).famiglia unless pignatti.at(i).at(0).euflora_id.blank?
      sheet1[posizione_y+6,posizione_x] = "Descrizione"
      sheet1[posizione_y+6,posizione_x+1] = Euflora.find(pignatti.at(i).at(0).euflora_id).descrizione unless pignatti.at(i).at(0).euflora_id.blank?
      sheet1[posizione_y+7,posizione_x] = "Specie"
      sheet1[posizione_y+7,posizione_x+1] = Euflora.find(pignatti.at(i).at(0).euflora_id).specie unless pignatti.at(i).at(0).euflora_id.blank?
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

  def create_com_xls(pignatti,euflora)
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
      sheet1[posizione_y+4,posizione_x+1] = Euflora.find(pignatti.at(i).at(0).euflora_id).codice_eu unless pignatti.at(i).at(0).euflora_id.blank?
      sheet1[posizione_y+5,posizione_x] = "Famiglia"
      sheet1[posizione_y+5,posizione_x+1] = Euflora.find(pignatti.at(i).at(0).euflora_id).famiglia unless pignatti.at(i).at(0).euflora_id.blank?
      sheet1[posizione_y+6,posizione_x] = "Descrizione"
      sheet1[posizione_y+6,posizione_x+1] = Euflora.find(pignatti.at(i).at(0).euflora_id).descrizione unless pignatti.at(i).at(0).euflora_id.blank?
      sheet1[posizione_y+7,posizione_x] = "Specie"
      sheet1[posizione_y+7,posizione_x+1] = Euflora.find(pignatti.at(i).at(0).euflora_id).specie unless pignatti.at(i).at(0).euflora_id.blank?
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


    euflora_list = split_data(euflora)

    for z in 0..euflora_list.size-1
      #SCHEDA EUFLORA

      #aggiungo un nuovo foglio di lavoro
      sheet2 = stat_file.create_worksheet :name => "Euflora#{z+1}"
      #nella prima riga metto le intestazioni
      #imposto un contatore di posizione
      posizione_y = 0
      posizione_x = 0

      #fix
      euflora = Array.new
      euflora = euflora + euflora_list.at(z)

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
        #salta di 12
        posizione_y += 12
      end

    end

    #creo la directory
    dir = "#{RAILS_ROOT}/public/Evoluzione Specie Complete/"
    #imposto il nome del file
    file_name = "tracking specie.xls"
    #imposto il full_path e la relative_path
    full_path = dir + file_name
    relative_path = "/Evoluzione Specie Complete/#{file_name}"
    require 'ftools'
    File.makedirs dir
    #scrivo il file
    stat_file.write "#{RAILS_ROOT}/public/Evoluzione Specie Complete/#{file_name}"
    #creo l'oggetto file
    new_stat_file = OutputFile.new
    new_stat_file.fill_and_save(file_name,full_path,relative_path,"Tracking Specie")
    return new_stat_file
  end

  def split_data(euflora)
    #contiene i dati finali
    data_array = Array.new
    #converto in numero di record effettivi del file
    #e li divido per la lunghezza massima ottenendo il numero di split da fare
    #che corrisponderebbe al numero di fogli da creare arrotondato per eccesso
    numero_split = ((euflora.size.to_f * 15) / 65000).ceil
    #calcolo il numero di elementi per pagina
    ele_pag = euflora.size.to_i / numero_split.to_i
    #contiene dati provvisori
    temp = Array.new
    #serve per l'algoritmo
    limite = ele_pag
    #splitto
    #scorro tutti gli elementi
    for x in 0..euflora.size-1
      #se l'elemento corrente rientra nel limite per pagina
      if x <= limite
        #memorizzo l'elemento corrente nell'array temporaneo corrente
        temp << euflora.at(x)
      #se non rientra nel limite
      else
        #aggiungo i dati memorizzati finora nell'array temporaneo,
        # nell'array dei dati finali
        data_array << temp
        #creo un nuovo array temporaneo
        temp = Array.new
        #ci memorizzo l'elemento corrente che non può venir perso
        temp << euflora.at(x)
        #incremento il limite di un altra pagina
        limite += ele_pag
      end
      if x == euflora.size-2
        data_array << temp
      end
    end
    return data_array
  end

end
