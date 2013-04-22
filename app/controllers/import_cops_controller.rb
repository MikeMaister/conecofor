class ImportCopsController < ApplicationController

  before_filter :campaign_active?, :only => "index"
  before_filter :only =>"beginning" do |controller| controller.delete_old_record_cache!("Cops") end

  def index
    @active_campaign = Campagne.find(:first, :conditions => ["active = true"])
  end

  def beginning
    #azzero tutte le variabili di sessione
    session_reset!

    #se non tutti i campi sono stati compilati
    if params[:upload].blank?
      #avviso
      flash[:error] = "Riempi tutti i campi prima di proseguire."
      redirect_to :controller => "import_cops"
    #se il file non ha estenzione valida o è di un altro tipo di rilevamento
    elsif !valid_file_kind?(params[:upload],"cops")
      flash[:error] = "Tipo di file non valido."
      redirect_to :controller => "import_cops"
    else
      #rintraccio la campagna aperta
      @open_camp = Campagne.find(:first, :conditions => ["active = true"])
      #se non c'è nessuna campagna aperta
      if @open_camp.blank?
        flash[:error] = "Nessuna campagna è disponibile per l'import."
        redirect_to :controller => "import_cops", :action => "index"
      else
        #se il nome del file non corrisponde alla campagna aperta
        if @open_camp.inizio.year != year_from_file_name(params[:upload])
          #lancio l'errore
          flash[:error] = "Il nome del file non corrisponde con la campagna aperta."
          redirect_to :controller => "import_cops", :action => "index"
        else

          #carico la maschera d'obbligatorietà nella sessione
          session[:mask_name] = MandatoryMask.find(MandatoryMaskAssociation.find(:first,:conditions => ["campagna_id = ?",@open_camp.id]).mandatory_mask_id).mask_name

          #se il file è già stato importato
          if imported_file?(params[:upload],@open_camp)
            #lo aggiorno
            update_file!(params[:upload],@open_camp,"Cops")
          #se il file non è già stato importato
          else
            #upload del file + traccia nel db
            upload_save_file!(params[:upload],@open_camp,"Cops")
          end
          #proseguo con l'import del file
          redirect_to :controller => "import_cops" , :action => "import"
        end
      end
    end
  end

  def import

    require 'rubygems'
    gem 'ruby-ole','1.2.11.4'
    require 'spreadsheet'

    #rintraccio il file da importare
     file_to_import = ImportFile.find(session[:file_id])
    #imposto la codifica dei caratteri
    Spreadsheet.client_encoding = 'UTF-8'
    #apro il file
    doc = Spreadsheet.open file_to_import.path
    #imposto il foglio di lavoro
    sheet = doc.worksheet 0
    #imposto la variabile d'errore su tutto il file
    session[:file_error] = false
    #scorro il file
    sheet.each_with_index do |row,i|
      # a meno che l'intera riga non sia vuota (EOF)
      unless row[0].blank? && row[1].blank? && row[2].blank? && row[3].blank? && row[4].blank? && row[5].blank? && row[6].blank? && row[7].blank? && row[8].blank? && row[9].blank? && row[10].blank?
        #fa saltare la prima riga
        if i != 0
          #memorizzo il record temporaneo
          #CORRISPONDENZA ALLE COLONNE DEL FILE
          record = FileRowCops.new(row[0],row[1],row[2],row[3],row[4],row[5],row[7],row[8],row[9],row[6],row[10])
          #variabile flag per controllare se ci sono stati errori nella riga analizzata
          session[:row_error] = false
          #Check 1: Formato dati
          data_format(record,i)
          #dopo aver controllato il formato dati, forzo i dati ad essere corretti
          record.force_data_format
          #eseguo gli altri check solo se sulla riga corrente non ci sono stati errori del tipo data_format
          unless session[:row_error]
            #Check 2: Obbligatorietà campi
            null_check(record,i)
            #eseguo gli altri check solo se sulla riga corrente non ci sono stati errori del tipo null_check
            unless session[:row_error]
              #Check 3: Riferimento a tabelle
              external_reference_check(record,i)
              #eseguo gli altri check solo se sulla riga corrente non ci sono stati errori del tipo external_reference_check
              unless session[:row_error]
                #Check 8: Dominio degli attributi
                attr_domain(record,i)
                #eseguo gli altri check solo se sulla riga corrente non ci sono stati errori del tipo attr_domain
                unless session[:row_error]
                  #Check 4: Unicità record
                  unique_record_check(record,i)
                  #eseguo gli altri check solo se sulla riga corrente non ci sono stati errori del tipo unique_record
                  unless session[:row_error]
                    #Check 5: Corrispondenza nome_file - plot
                    file_name_plot_to_plot(record,i)
                    #Check 6: Corrispondenza nome_file - data
                    file_name_date_to_date(record,i)
                    #Check 7: Corrispondenza stagione file - stagione campagna
                    file_season(record,i)
                    #memorizzo la riga solo se ha passato tutti i check compliance
                    unless session[:row_error]
                      #memorizzo la riga
                      compliance_row = Cops.new
                      compliance_row.fill_temp(record,session[:file_id],i+1)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    #a fine parsing dell'intero file controllo se c'è stato almeno un errore;
    #se c'è stato
    if session[:file_error]

      #NOTA: [TO_DO]: DEVE DIVENTARE UNA COSA ATOMICA (collegata all'utente, o al file in sessione ad esempio),
      #altrimenti si rischierebbe di cancellare record di altri utenti.(E' già parzialmente così)

      #carico il file che sto analizzando
      file = ImportFile.find(session[:file_id])
      #cancello in cops tutti i record temporanei memorizzati (cancello la cache per gli altri check)
      Cops.connection.execute("DELETE FROM cops WHERE temp = true AND file_name_id = #{session[:file_id]} AND import_num = #{file.import_num}")

      #faccio il redirect verso il riepilogo degli errori trovati
      redirect_to :controller => "import_cops", :action => "comp_error_summary"
    #se non c'è stato nessun errore
    else
      #proseguo con la procedura di import verso i simple range check
      redirect_to :controller => "import_cops", :action => "simple_range_check"
    end
  end

  def simple_range_check
    #carico il file che sto analizzando
    file = ImportFile.find(session[:file_id])
    #carico tutti i record temporanei del file attuale(cosiderando le volte che è stato importato) su cui effettuare i check
    rows = Cops.find(:all, :conditions => ["temp = true AND file_name_id = ? AND import_num = ?",session[:file_id],file.import_num])
    #se non ci sono record da controllare
    if rows.blank?
      #non va bene, avverto
      flash[:error] = "Il file è vuoto"
      redirect_to :controller => "import_cops"
    #altrimenti effettuo i check
    else
      #setto errori e warning a 0
      session[:sr_error] = false
      session[:sr_warning] = false
      #scorro i record da controllare
      for i in (0..rows.size-1)
        #SR Check 1
        data_range(rows.at(i))
      end
      #se non c'è stato nemmeno un errore
      #proseguo con i multiplerange, altrimenti
      #visualizzo la schermata riassuntiva,
      #con possibilità di forzare i dati errati,
      #che si possono forzare.
      if session[:sr_error] == false && session[:sr_warning] == false
        #proseguo con i tipi di check successivi
        redirect_to :controller => "import_cops", :action => "multiple_parameter_check"
      else
        flash[:error]="Controlla il report."
        redirect_to :controller => "import_cops", :action => "sr_error_summary"
      end
    end
  end

  def multiple_parameter_check
    #carico la campagna attiva
    open_camp = Campagne.find(:first,:conditions => ["active = true"])
    #carico il file che sto analizzando
    file = ImportFile.find(session[:file_id])
    #carico tutti i record temporanei del file attuale(cosiderando le volte che è stato importato) su cui effettuare i check
    rows = Cops.find(:all, :conditions => ["temp = true AND file_name_id = ? AND import_num = ? AND campagne_id = ?",session[:file_id],file.import_num,open_camp.id])
    #setto gli errori mp a 0
    session[:mp_error] =  false
    #scorro i record da controllare
    for i in (0..rows.size-1)
      #MP check 1
      specie_eu(rows.at(i))
    end
    #controllo gli errori globali
    #MP check 2
    all_subplot?
    #se non si è verificato nessun errore
    if session[:mp_error] == false
      #levo il flag di record temporaneo a tutti i record relativi a quest'import
      for i in 0..rows.size-1
        rows.at(i).permanent!
      end
      flash[:notice]="Complimenti nessun errore"
      redirect_to :controller => "import_cops"
    #se si è verificato almeno 1 errore mostro il riepilogo degli errori
    elsif session[:mp_error] == true
      flash[:error]="Controlla il report."
      redirect_to :controller => "import_cops", :action => "mp_error_summary"
    end
  end

  def mp_error_summary
    #carico il file
    @file = ImportFile.find(session[:file_id])
    #carico gli errori
    @mp_err = ErrorCops.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Multipleparameter' ",session[:file_id],@file.import_num])
    #carico gli errori globali
    @mp_gbe = ErrorCops.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Global Error' ",session[:file_id],@file.import_num])

  end

  def sr_error_summary
    #carico il file
    @file = ImportFile.find(session[:file_id])
    #carico gli errori
    @sr_err = ErrorCops.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Simplerange' ",session[:file_id],@file.import_num])
  end

  #riassunto errori derivari dai check compliance
  def comp_error_summary
    #carico il file
    @file = ImportFile.find(session[:file_id])
    #carico tutti gli errori compliance determinati da questa sessione
    #cioè tutti gli errori che corrispondono al numero di volte che è stato importato il file
    #ogni import ha i suoi errori, in base alla variabile import_num
    @comp_err = ErrorCops.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Compliance' ",session[:file_id],@file.import_num])
  end

  private

  #MP CHECK N2: presenza di tutti i subplot
  def all_subplot?
    #trovo la campagna aperta
    open_camp = Campagne.find(:first,:conditions => ["active = true"])
    #carico il file
    file = ImportFile.find(session[:file_id])
    #memorizzo il numero dei subplot diversi tra loro interni
    num_su_in = Cops.count_by_sql("SELECT COUNT(DISTINCT subplot) FROM cops WHERE campagne_id = #{open_camp.id} AND in_out = 1 AND import_num = #{file.import_num} AND file_name_id = #{file.id}")
    #memorizzo il numero dei subplot diversi tra loro esterni
    num_su_out = Cops.count_by_sql("SELECT COUNT(DISTINCT subplot) FROM cops WHERE campagne_id = #{open_camp.id} AND in_out = 2 AND import_num = #{file.import_num} AND file_name_id = #{file.id}")

    #se i subplot interni non sono 12
    if num_su_in != 12
      #segnalo l'errore
      global_error("Mancano alcuni subplot interni",file)
    end
    #se i subplot esterni non sono 12
    if num_su_out != 12
      #segnalo l'errore
      global_error("Mancano alcuni subplot esterni",file)
    end
  end

  #MP CHECK N1: specie eu
  def specie_eu(record)
    str = /^[3-5]/
    #se il codice strato è uguale a 4
    if record.codice_strato == 4
      #rintraccio la specie del record attuale
      specie = Specie.find(record.specie_id)
      #se la specie europea corrispondente esiste
      unless specie.euflora_id.blank?
        #la rintraccio rintraccio
        eu_specie = Euflora.find(specie.euflora_id)
        #a meno che il codice europeo della specie del record non inizi per 3,4 o 5 allora c'è un errore
        unless eu_specie.codice_eu.to_s =~ str
          #segnalo l'errore
          multiple_parameter_error(record,"[strato - specie - eu code] violation")
        end
      end
    end
  end

  #errore globale, ossia non dipendente da un record specifico
  def global_error(error,file)
    #creo un nuovo errore
    gb_e = ErrorCops.new
    #compilo l'errore globale
    gb_e.global_error_fill_and_save(error,file)
    #segnalo che c'è stato un errore
    session[:mp_error] = true
  end

  def multiple_parameter_error(record,error)
    #creo un nuovo errore
    @mp_error = ErrorCops.new
    #compilo l'errore
    @mp_error.fill_and_save_from_db(record,"Multipleparameter",error,session[:file_id])
    session[:mp_error] = true
  end

  #SR CHECK N1: DATA RECORD in DATA CAMPAGNA
  def data_range(record)
    #carico la campagna attiva
    camp = Campagne.find(:first,:conditions => ["active = true"])
    #a meno che la data non rientri nel range della campagna
    unless record.data >= camp.inizio && record.data <= camp.fine
      #salvo l'errore simple range
      simple_range_error(record,"Data range")
    end
  end

  def simple_range_error(record,error)
    #creo un nuovo errore
    @sr_error = ErrorCops.new
    #compilo l'errore
    @sr_error.fill_and_save_from_db(record,"Simplerange",error,session[:file_id])
    session[:sr_error] = true
  end

  def save_error(record,error,row)
    @error = ErrorCops.new
    @error.fill_and_save_from_file(record,"Compliance",error,row+1,session[:file_id])
  end

  #CHECK N7: CORRISPONDENZA STAGIONE FILE - STAGIONE CAMPAGNA
  def file_season(record,row)
    camp_season_identifier = Season.find(Campagne.find(:first,:conditions => ["active = true"]).season_id).identifier
    #a meno che il numero di stagione corrisponda a quella scelta dall'utente
    unless record.priest == camp_season_identifier
      #salvo l'errore
      save_error(record,"Stagione campagna - Stagione file",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
  end

  #CHECK N8: DOMINIO DEGLI ATTRIBUTI
  def attr_domain(record,row)
    #SUBPLOT
    #a meno che il numero di subplot sia incluso tra 1 e 12
    unless (1..12).include?(record.subplot)
      #salvo l'errore
      save_error(record,"Wrong subplot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #IN_OUT
    #a meno che esterno valga 1 o 2
    unless (1..2).include?(record.in_out)
      #salvo l'errore
      save_error(record,"Wrong in_out",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #PRIEST
    #a meno che priest valga 1 o 2
    #unless (1..2).include?(record.priest)
    est_identifier = Season.find_by_nome("Estate").identifier
    pri_identifier = Season.find_by_nome("Primavera").identifier
    unless record.priest == est_identifier || record.priest == pri_identifier
      #salvo l'errore
      save_error(record,"Wrong Pri/Est",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #COD_STRATO
    #a meno che cod_strato valga 1,2,3 o 4
    unless (1..4).include?(record.cod_strato)
      #salvo l'errore
      save_error(record,"Wrong Cod_strato",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
  end

  #CHECK N6: CORRISPONDENZA NOME FILE - Data
  def file_name_date_to_date(record,row)
    #rintraccio il file
    file = ImportFile.find(session[:file_id])
    #campagna 199X
    camp90 = /([9])(\d)\D+\d+[.]\S*/
    #campagna 20XX in avanti
    camp00 = /(\d+)\D+\d+[.]\S*/
    #se il file si riferisce alle campagne dal 1990 al 1999
    if file.file_name =~ camp90
      #anno = 19 + numeri rimanenti
      anno = "19" + $1 + $2
      #se il file si riferisce alle campagne dal 2000 al 2099
    elsif file.file_name =~ camp00
      #anno = 20 + numeri rimanenti
      anno = "20" + $1
    end
    #memorizzo temporaneamente la data per poterci lavorare sopra
    data_temp = Cops.new
    data_temp.data = record.data
    #a meno che l'anno della data del record non corrisponda a quello del nome del file
    unless data_temp.data.year == anno.to_i
      #salvo l'errore
      save_error(record,"File name - Data",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
  end

  #CHECK N5: CORRISPONDENZA NOME FILE - PLOT
  def file_name_plot_to_plot(record,row)
    #rintraccio il file
    file = ImportFile.find(session[:file_id])
    #numero del plot
    plot_number = /\d+\D+(\d+)[.]\S*/
    #confronto
    file.file_name =~ plot_number
    #estrapolo il numero del plot
    file_plot = $1
    file_plot = file_plot.to_i
    #se il plot indicato nel nome del file non è uguale a quello contenuto all'interno
    unless file_plot == record.cod_plot
      #salvo l'errore
      save_error(record,"File name - Plot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
  end

  #CHECK N4: UNICITA' RECORD
  def unique_record_check(record,row)
    #recupero tutte le info necessarie per memorizzare la chiave primaria
    plot_id = Plot.find(:first,:conditions => ["numero_plot = ? AND deleted = false",record.cod_plot]).id
    specie_id = Specie.find(:first, :conditions => ["descrizione = ?", record.specie]).id
    active_campaign_id = Campagne.find(:first,:conditions => ["active = true"]).id
    file = ImportFile.find(session[:file_id])
    #cerco la chiave primaria
    pk = Cops.find(:first,:conditions => ["campagne_id = ? AND plot_id = ? AND subplot = ? AND in_out = ? AND specie_id = ? AND codice_strato = ? AND priest = ? AND file_name_id = ? AND import_num = ?", active_campaign_id, plot_id, record.subplot, record.in_out, specie_id, record.cod_strato, record.priest, file.id, file.import_num])
    #se già è presente
    if pk
      #salvo l'errore
      save_error(record,"Duplicate row",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
  end

  #CHECK N3: RIFERIMENTO A TABELLE
  def external_reference_check(record,row)
    #riferimenti al plot
    plot = Plot.find(:first, :conditions => ["numero_plot = ? AND deleted = false", record.cod_plot])
    #se il plot non esiste
    if plot.blank?
      save_error(record,"Riferimento al Plot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #riferimenti alla specie
    specie = Specie.find(:first, :conditions => ["descrizione = ?", record.specie])
    #se la specie non esiste
    if specie.blank?
      save_error(record,"Riferimento a Specie",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #riferimenti alla copertura specifica
    unless record.copertura.blank?
      cop_spec = CoperturaSpecifica.find(:first, :conditions => ["identifier = ?",record.copertura])
      if cop_spec.blank?
        save_error(record,"Riferimento a Copertura Specifica",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    #riferimenti a substrate
    unless record.substrate.blank?
      sub = SubstrateType.find(:first, :conditions => ["code = ?",record.substrate])
      if sub.blank?
        save_error(record,"Riferimento a Substrate Type",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    #riferimenti a substrate
    unless record.certainty_species_determination.blank?
      csd = CertaintySpeciesDetermination.find(:first, :conditions => ["code = ?",record.certainty_species_determination])
      if csd.blank?
        save_error(record,"Riferimento a Certainty Species Determination",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
  end

  #CHECK N2: OBBLIGATORIETA' CAMPI
  def null_check(record,row)
    #se gli attributi obbligatori sono nulli
    if record.data.blank?
      #registro l'errore
      save_error(record,"Violazione not null - Data",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.cod_plot.blank?
      #registro l'errore
      save_error(record,"Violazione not null - Plot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.subplot.blank?
      #registro l'errore
      save_error(record,"Violazione not null - Subplot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.in_out.blank?
      #registro l'errore
      save_error(record,"Violazione not null - In/Out",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.priest.blank?
      #registro l'errore
      save_error(record,"Violazione not null - Pri/Est",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.cod_strato.blank?
      #registro l'errore
      save_error(record,"Violazione not null - Strato",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.specie.blank?
      #registro l'errore
      save_error(record,"Violazione not null - Specie",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #FACOLTATIVI
    if mandatory?(session[:mask_name],"Cops","copertura_specifica") == true
      if record.copertura.blank?
        #registro l'errore
        save_error(record,"Violazione not null - Copertura",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Cops","substrate")
      if record.substrate.blank?
        #registro l'errore
        save_error(record,"Violazione not null - Substrate",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Cops","certainty_species_determination")
      if record.certainty_species_determination.blank?
        #registro l'errore
        save_error(record,"Violazione not null - Certainty Species Determination",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
  end

  #CHECK N1: FORMATO DATI
  #controllo che i campi integer abbiano effettivamente valori interi immessi
  def data_format(record,row)
    #è una stringa
    stringa = /\D+/
    #se i dati che dovrebbero essere un numero,in realtà sono una stringa
    if record.cod_plot =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Plot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.subplot =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Subplot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.in_out =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - In/Out",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.priest =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Pri/Est",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.cod_strato =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Strato",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.substrate =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Substrate Type",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.certainty_species_determination =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Certainty Species Determination",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
  end

end
