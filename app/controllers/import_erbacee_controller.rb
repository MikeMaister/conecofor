class ImportErbaceeController < ApplicationController

  before_filter :only =>"beginning" do |controller| controller.delete_old_record_cache!("Erbacee") end
  before_filter :campaign_active?, :only => "index"

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
      redirect_to :controller => "import_erbacee"
      #se il file non ha estenzione valida o è di un altro tipo di rilevamento
    elsif !valid_file_kind?(params[:upload],"erb")
      flash[:error] = "Tipo di file non valido."
      redirect_to :controller => "import_erbacee"
    else
      #rintraccio la campagna aperta
      @open_camp = Campagne.find(:first, :conditions => ["active = true"])
      #se non c'è nessuna campagna aperta
      if @open_camp.blank?
        flash[:error] = "Nessuna campagna è disponibile per l'import."
        redirect_to :controller => "import_erbacee"
      else
        #se il nome del file non corrisponde alla campagna aperta
        if @open_camp.inizio.year != year_from_file_name(params[:upload])
          #lancio l'errore
          flash[:error] = "Il nome del file non corrisponde con la campagna aperta."
          redirect_to :controller => "import_erbacee"
        else

          #carico la maschera d'obbligatorietà nella sessione
          session[:mask_name] = MandatoryMask.find(MandatoryMaskAssociation.find(:first,:conditions => ["campagna_id = ?",@open_camp.id]).mandatory_mask_id).mask_name

          #se il file è già stato importato
          if imported_file?(params[:upload],@open_camp)
            #lo aggiorno
            update_file!(params[:upload],@open_camp,"Erbacee")
            #se il file non è già stato importato
          else
            #upload del file + traccia nel db
            upload_save_file!(params[:upload],@open_camp,"Erbacee")
          end
          #proseguo con l'import del file
          redirect_to :controller => "import_erbacee" , :action => "import"
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
      unless row[0].blank? && row[1].blank? && row[2].blank? && row[4].blank? && row[5].blank? && row[6].blank? && row[7].blank? && row[8].blank? && row[9].blank? && row[10].blank? && row[11].blank? && row[12].blank? && row[13].blank? && row[14].blank? && row[15].blank?
        #fa saltare la prima riga
        if i != 0
          #memorizzo il record temporaneo
          #CORRISPONDENZA ALLE COLONNE DEL FILE
          record = FileRowErbacee.new(row[0],row[1],row[2],row[4],row[5],row[6],row[7],row[8],row[9],row[10],row[11],row[12],row[13],row[14],row[15])
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
                    #memorizzo la riga solo se ha passato tutti i check compliance
                    unless session[:row_error]
                      compliance_row = Erbacee.new
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
      #cancello in legnose tutti i record temporanei memorizzati (cancello la cache per gli altri check)
      Erbacee.connection.execute("DELETE FROM erbacee WHERE temp = true AND file_name_id = #{session[:file_id]} AND import_num = #{file.import_num}")

      #faccio il redirect verso il riepilogo degli errori trovati
      redirect_to :controller => "import_erbacee", :action => "comp_error_summary"
      #se non c'è stato nessun errore
    else
      #proseguo con la procedura di import verso i simple range check
      redirect_to :controller => "import_erbacee", :action => "simple_range_check"
    end
  end

  #riassunto errori derivari dai check compliance
  def comp_error_summary
    #carico il file
    @file = ImportFile.find(session[:file_id])
    #carico tutti gli errori compliance determinati da questa sessione
    #cioè tutti gli errori che corrispondono al numero di volte che è stato importato il file
    #ogni import ha i suoi errori, in base alla variabile import_num
    @comp_err = ErrorErbacee.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Compliance' ",session[:file_id],@file.import_num])
  end

  def simple_range_check
    #carico il file che sto analizzando
    file = ImportFile.find(session[:file_id])
    #caricol tutti i record temporanei del file attuale(cosiderando le volte che è stato importato) su cui effettuare i check
    rows = Erbacee.find(:all, :conditions => ["temp = true AND file_name_id = ? AND import_num = ?",session[:file_id],file.import_num])
    #se non ci sono record da controllare
    if rows.blank?
      #non va bene, avverto
      flash[:error] = "Il file è vuoto"
      redirect_to :controller => "import_erbacee"
      #altrimenti effettuo i check
    else
      #setto errori e warning a 0
      session[:sr_error] = false
      #scorro i record da controllare
      for i in (0..rows.size-1)
        #SR Check 1
        data_range(rows.at(i))
        #applico i src
        do_src_on_rows(rows.at(i),file.campagne_id)
      end
      #se non c'è stato nemmeno un errore, proseguo con i multiplerange, altrimenti, visualizzo la schermata riassuntiva
      if session[:sr_error] == false
        #proseguo con i tipi di check successivi
        redirect_to :controller => "import_erbacee", :action => "multiple_parameter_check"
      else
        flash[:error]="Controlla il report."
        redirect_to :controller => "import_erbacee", :action => "sr_error_summary"
      end
    end
  end

  def sr_error_summary
    #carico il file
    @file = ImportFile.find(session[:file_id])
    #carico gli errori
    @sr_err = ErrorErbacee.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Simplerange' ",session[:file_id],@file.import_num])
  end


  def multiple_parameter_check
    #carico la campagna attiva
    open_camp = Campagne.find(:first,:conditions => ["active = true"])
    #carico il file che sto analizzando
    file = ImportFile.find(session[:file_id])
    #carico tutti i record temporanei del file attuale(cosiderando le volte che è stato importato) su cui effettuare i check
    rows = Erbacee.find(:all, :conditions => ["temp = true AND file_name_id = ? AND import_num = ? AND campagne_id = ?",session[:file_id],file.import_num,open_camp.id])
    #setto gli errori mp a 0
    session[:mp_error] =  false
    #MP CHECK N.1
    all_subplot_100?
    #check su ogni record
    for i in 0..rows.size-1
      #MP CHECK N.2
      cop0_null(rows.at(i))
      #MP CHECK N.3
      hedera_helix_check(rows.at(i))
    end

    #se non si è verificato nessun errore
    if session[:mp_error] == false
      #levo il flag di record temporaneo a tutti i record relativi a quest'import
      for i in 0..rows.size-1
        rows.at(i).permanent!
      end
      flash[:notice]="Complimenti nessun errore"
      redirect_to :controller => "import_erbacee"
      #se si è verificato almeno 1 errore mostro il riepilogo degli errori
    elsif session[:mp_error] == true
      flash[:error]="Controlla il report."
      redirect_to :controller => "import_erbacee", :action => "mp_error_summary"
    end
  end

  def mp_error_summary
    #carico il file
    @file = ImportFile.find(session[:file_id])
    #carico gli errori
    @mp_err = ErrorErbacee.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Multipleparameter' ",session[:file_id],@file.import_num])
    #carico gli errori globali
    @mp_gbe = ErrorErbacee.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Global Error' ",session[:file_id],@file.import_num])
  end

  private

  #MP CHECK N3: Se la specie è 'HEDERA HELIX', copertura e copertura esterna devono essere not null, mentre gli altri attributi null
  def hedera_helix_check(row)
    unless row.specie_id.blank?
    #cerco la specie Hedera helix
    hedera_helix = Specie.find(:first,:conditions => ["descrizione = 'Hedera helix' AND deleted = false"])
      if row.specie_id == hedera_helix.id
        unless !row.copertura.nil? && !row.copertura_esterna.nil? && row.altezza_media.nil? && row.numero_cespi.nil? && row.numero_stoloni.nil? && row.numero_stoloni_radicanti.nil? && row.numero_foglie.nil? && row.numero_getti.nil?
          #segnalo l'errore
          multiple_parameter_error(row,"Hedera Helix check")
        end
      end
    end
  end

  #MP CHECK N2: Quando la copertura = 0 tutti gli altri campi devono essere null
  def cop0_null(row)
    unless row.copertura.nil?
      if row.copertura == 0
        unless  row.copertura_esterna.nil? && row.altezza_media.nil? && row.numero_cespi.nil? && row.numero_stoloni.nil? && row.numero_stoloni_radicanti.nil? && row.numero_foglie.nil? && row.numero_getti.nil?
          #segnalo l'errore
          multiple_parameter_error(row,"Se la copertura = 0, non devono essere presenti altri parametri.")
        end
      end
    end
  end

  def multiple_parameter_error(record,error)
    #creo un nuovo errore
    @mp_error = ErrorErbacee.new
    #compilo l'errore
    @mp_error.fill_and_save_from_db(record,"Multipleparameter",error,session[:file_id])
    #segnalo che c'è stato un errore
    session[:mp_error] = true
  end

  #MP CHECK N1: presenza di tutti i subplot
  def all_subplot_100?
    #trovo la campagna aperta
    open_camp = Campagne.find(:first,:conditions => ["active = true"])
    #carico il file
    file = ImportFile.find(session[:file_id])
    #memorizzo il numero dei subplot diversi tra loro interni
    num_su_in = Erbacee.count_by_sql("SELECT COUNT(DISTINCT subplot) FROM erbacee WHERE campagne_id = #{open_camp.id} AND import_num = #{file.import_num} AND file_name_id = #{file.id}")

    #se i subplot non sono 100
    if num_su_in != 100
      #segnalo l'errore
      global_error("Mancano alcuni subplot",file)
    end
  end

  #errore globale, ossia non dipendente da un record specifico
  def global_error(error,file)
    #creo un nuovo errore
    gb_e = ErrorErbacee.new
    #compilo l'errore globale
    gb_e.global_error_fill_and_save(error,file)
    #segnalo che c'è stato un errore
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

  #SR CHECK N2
  def do_src_on_rows(row,camp_id)
    #Legnose N.1
    unless row.copertura.nil?
      copertura = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'copertura' AND reference_table = 'erbacee' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
      unless row.copertura <= copertura[0].max && row.copertura >= copertura[0].min
        #registro l'errore 'out of range NOME CAMPO'
        simple_range_error(row,"Out of range: #{copertura[0].attr}")
      end
    end
    #Legnose N.2
    #solo se altezza_media non è nullo
    unless row.altezza_media.nil?
      altezza_media = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'altezza_media' AND reference_table = 'erbacee' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
      unless row.altezza_media <= altezza_media[0].max && row.altezza_media >= altezza_media[0].min
        #registro l'errore 'out of range NOME CAMPO'
        simple_range_error(row,"Out of range: #{altezza_media[0].attr}")
      end
    end
    #Legnose N.3
    #solo se numero_cespi non è nullo
      unless row.numero_cespi.nil?
        n_cespi = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'numero_cespi' AND reference_table = 'erbacee' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
        unless row.numero_cespi <= n_cespi[0].max && row.numero_cespi >= n_cespi[0].min
          #registro l'errore 'out of range NOME CAMPO'
          simple_range_error(row,"Out of range: #{n_cespi[0].attr}")
        end
      end
    #Legnose N.4
    #solo se numero_stoloni non è nullo
      unless row.numero_stoloni.nil?
        n_stoloni = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'numero_stoloni' AND reference_table = 'erbacee' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
        unless row.numero_stoloni <= n_stoloni[0].max && row.numero_stoloni >= n_stoloni[0].min
          #registro l'errore 'out of range NOME CAMPO'
          simple_range_error(row,"Out of range: #{n_stoloni[0].attr}")
        end
      end
    #Legnose N.5
    #solo se numero_stoloni_radicanti non è nullo
      unless row.numero_stoloni_radicanti.nil?
        n_stoloni_rad = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'numero_stoloni_radicanti' AND reference_table = 'erbacee' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
        unless row.numero_stoloni_radicanti <= n_stoloni_rad[0].max && row.numero_stoloni_radicanti >= n_stoloni_rad[0].min
          #registro l'errore 'out of range NOME CAMPO'
          simple_range_error(row,"Out of range: #{n_stoloni_rad[0].attr}")
        end
      end
    #Legnose N.6
    #solo se numero_foglie non è nullo
      unless row.numero_foglie.nil?
        n_foglie = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'numero_foglie' AND reference_table = 'erbacee' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
        unless row.numero_foglie <= n_foglie[0].max && row.numero_foglie >= n_foglie[0].min
          #registro l'errore 'out of range NOME CAMPO'
          simple_range_error(row,"Out of range: #{n_foglie[0].attr}")
        end
      end
    #Legnose N.7
    #solo se numero_getti non è nullo
      unless row.numero_getti.nil?
        n_getti = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'numero_getti' AND reference_table = 'erbacee' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
        unless row.numero_getti <= n_getti[0].max && row.numero_getti >= n_getti[0].min
          #registro l'errore 'out of range NOME CAMPO'
          simple_range_error(row,"Out of range: #{n_getti[0].attr}")
        end
      end
  end

  def simple_range_error(record,error)
    #creo un nuovo errore
    @sr_error = ErrorErbacee.new
    #compilo l'errore
    @sr_error.fill_and_save_from_db(record,"Simplerange",error,session[:file_id])
    #segnalo che c'è stato un errore
    session[:sr_error] = true
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
    data_temp = Erbacee.new
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

  #CHECK N4: UNICITA' RECORD
  def unique_record_check(record,row)
    #una stessa specie deve essere presente 1 sola volta per ogni specifico plot-subplot
    if !record.specie.blank?
      #recupero tutte le info necessarie per memorizzare la chiave primaria
      plot_id = Plot.find(:first,:conditions => ["numero_plot = ? AND deleted = false",record.cod_plot]).id
      specie_id = Specie.find(:first, :conditions => ["descrizione = ? AND deleted = false", record.specie]).id
      active_campaign_id = Campagne.find(:first,:conditions => ["active = true"]).id
      file = ImportFile.find(session[:file_id])
      #cerco la chiave primaria
      pk = Erbacee.find(:first,:conditions => ["campagne_id = ? AND plot_id = ? AND subplot = ? AND file_name_id = ? AND import_num = ? AND specie_id = ?", active_campaign_id, plot_id, record.subplot, file.id, file.import_num,specie_id])
      #se già è presente
      unless pk.blank?
        #salvo l'errore
        save_error(record,"Specie già presente per il plot-subplot indicato",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
  end

  #CHECK N8: DOMINIO DEGLI ATTRIBUTI
  def attr_domain(record,row)
    #SUBPLOT
    #a meno che il numero di subplot sia incluso tra 1 e 100
    unless (1..100).include?(record.subplot)
      #salvo l'errore
      save_error(record,"Wrong subplot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #COPERTURA ESTERNA
    #può essere 1 o nil
    unless record.copertura_esterna == 1 || record.copertura_esterna.nil?
      #salvo l'errore
      save_error(record,"Wrong Copertura Esterna",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #DANNI_MECCANICI
    #a meno che il campo non sia vuoto
    unless record.danni_meccanici.nil?
      #a meno che priest valga 0 o 1
      unless (0..1).include?(record.danni_meccanici)
        #salvo l'errore
        save_error(record,"Wrong danni_meccanici",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    #DANNI_PARASSITARI
    #a meno che il campo non sia vuoto
    unless record.danni_parassitari.nil?
      #a meno che priest valga 0 o 1
      unless (0..1).include?(record.danni_parassitari)
        #salvo l'errore
        save_error(record,"Wrong danni_parassitari",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
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
    #a meno che la specie non sia presente
    unless record.specie.blank?
      #riferimenti alla specie
      specie = Specie.find(:first, :conditions => ["descrizione = ? AND deleted = false", record.specie])
      #se la specie non esiste
      if specie.blank?
        save_error(record,"Riferimento a Specie",row)
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
    #Opzionali
    if mandatory?(session[:mask_name],"Erbacee","copertura")
      if record.copertura.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Copertura",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","copertura_esterna")
      if record.copertura_esterna.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Copertura Esterna",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","altezza_media")
      if record.altezza_media.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Altezza Media",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","numero_cespi")
      if record.numero_cespi.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Numero Cespi",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","numero_stoloni")
      if record.numero_stoloni.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Numero Stoloni",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","numero_stoloni_radicanti")
      if record.numero_stoloni_radicanti.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Numero Stoloni Radicanti",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","numero_foglie")
      if record.numero_foglie.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Numero Foglie",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","numero_getti")
      if record.numero_getti.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Numero Getti",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","danni_meccanici")
      if record.danni_meccanici.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Danni Meccanici",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","danni_parassitari")
      if record.danni_parassitari.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Danni Parassitari",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
  end

#CHECK N1: FORMATO DATI
#controllo che i campi integer e decimal abbiano effettivamente valori interi o decimali immessi
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
  if record.copertura =~ stringa
    #segnalo l'errore
    save_error(record,"Violazione tipo di dato - Copertura",row)
    #segnalo che c'è stato un errore sulla riga
    session[:row_error] = true
    #e segnalo l'errore sul file
    session[:file_error] = true
  end
  if record.copertura_esterna =~ stringa
    #segnalo l'errore
    save_error(record,"Violazione tipo di dato - Copertura Esterna",row)
    #segnalo che c'è stato un errore sulla riga
    session[:row_error] = true
    #e segnalo l'errore sul file
    session[:file_error] = true
  end
  if record.altezza_media =~ stringa
    #segnalo l'errore
    save_error(record,"Violazione tipo di dato - Altezza Media",row)
    #segnalo che c'è stato un errore sulla riga
    session[:row_error] = true
    #e segnalo l'errore sul file
    session[:file_error] = true
  end
  if record.numero_cespi =~ stringa
    #segnalo l'errore
    save_error(record,"Violazione tipo di dato - Numero Cespi",row)
    #segnalo che c'è stato un errore sulla riga
    session[:row_error] = true
    #e segnalo l'errore sul file
    session[:file_error] = true
  end
  if record.numero_stoloni =~ stringa
    #segnalo l'errore
    save_error(record,"Violazione tipo di dato - Numero Stoloni",row)
    #segnalo che c'è stato un errore sulla riga
    session[:row_error] = true
    #e segnalo l'errore sul file
    session[:file_error] = true
  end
  if record.numero_stoloni_radicanti =~ stringa
    #segnalo l'errore
    save_error(record,"Violazione tipo di dato - Numero Stoloni Radicanti",row)
    #segnalo che c'è stato un errore sulla riga
    session[:row_error] = true
    #e segnalo l'errore sul file
    session[:file_error] = true
  end
  if record.numero_foglie =~ stringa
    #segnalo l'errore
    save_error(record,"Violazione tipo di dato - Numero Foglie",row)
    #segnalo che c'è stato un errore sulla riga
    session[:row_error] = true
    #e segnalo l'errore sul file
    session[:file_error] = true
  end
  if record.numero_getti =~ stringa
    #segnalo l'errore
    save_error(record,"Violazione tipo di dato - Numero Getti",row)
    #segnalo che c'è stato un errore sulla riga
    session[:row_error] = true
    #e segnalo l'errore sul file
    session[:file_error] = true
  end
  if record.danni_meccanici =~ stringa
    #segnalo l'errore
    save_error(record,"Violazione tipo di dato - Danni Meccanici",row)
    #segnalo che c'è stato un errore sulla riga
    session[:row_error] = true
    #e segnalo l'errore sul file
    session[:file_error] = true
  end
  if record.danni_parassitari =~ stringa
    #segnalo l'errore
    save_error(record,"Violazione tipo di dato - Danni_parassitari",row)
    #segnalo che c'è stato un errore sulla riga
    session[:row_error] = true
    #e segnalo l'errore sul file
    session[:file_error] = true
  end
end

  def save_error(record,error,row)
    @error = ErrorErbacee.new
    @error.fill_and_save_from_file(record,"Compliance",error,row,session[:file_id])
  end

end

