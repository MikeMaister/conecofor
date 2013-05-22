class ImportLegnoseController < ApplicationController
  include Legn_checks

  before_filter :only =>"beginning" do |controller| controller.delete_old_record_cache!("Legnose") end
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
      redirect_to :controller => "import_legnose"
      #se il file non ha estenzione valida o è di un altro tipo di rilevamento
    elsif !valid_file_kind?(params[:upload],"leg")
      flash[:error] = "Tipo di file non valido."
      redirect_to :controller => "import_legnose"
    else
      #rintraccio la campagna aperta
      @open_camp = Campagne.find(:first, :conditions => ["active = true"])
      #se non c'è nessuna campagna aperta
      if @open_camp.blank?
        flash[:error] = "Nessuna campagna è disponibile per l'import."
        redirect_to :controller => "import_legnose"
      else
        #se il nome del file non corrisponde alla campagna aperta
        if @open_camp.inizio.year != year_from_file_name(params[:upload])
          #lancio l'errore
          flash[:error] = "Il nome del file non corrisponde con la campagna aperta."
          redirect_to :controller => "import_legnose"
        else

          #carico la maschera d'obbligatorietà nella sessione
          session[:mask_name] = MandatoryMask.find(MandatoryMaskAssociation.find(:first,:conditions => ["campagna_id = ?",@open_camp.id]).mandatory_mask_id).mask_name

          #se il file è già stato importato
          if imported_file?(params[:upload],@open_camp)
            #lo aggiorno
            update_file!(params[:upload],@open_camp,"Legnose")
            #se il file non è già stato importato
          else
            #upload del file + traccia nel db
            upload_save_file!(params[:upload],@open_camp,"Legnose")
          end
          #proseguo con l'import del file
          redirect_to :controller => "import_legnose" , :action => "import"
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
      unless row[0].blank? && row[1].blank? && row[2].blank? && row[3].blank? && row[4].blank? && row[5].blank? && row[6].blank? && row[7].blank? && row[8].blank? && row[9].blank? && row[10].blank? && row[11].blank?
        #fa saltare la prima riga
        if i != 0
          #memorizzo il record temporaneo
          #CORRISPONDENZA ALLE COLONNE DEL FILE
          record = FileRowLegnose.new(row[0],row[1],row[2],row[4],row[5],row[6],row[7],row[8],row[9],row[10],row[11])
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
                      #memorizzo la riga
                      compliance_row = Legnose.new
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
      Legnose.connection.execute("DELETE FROM legnose WHERE temp = true AND file_name_id = #{session[:file_id]} AND import_num = #{file.import_num}")

      #faccio il redirect verso il riepilogo degli errori trovati
      redirect_to :controller => "import_legnose", :action => "comp_error_summary"
      #se non c'è stato nessun errore
    else
      #proseguo con la procedura di import verso i simple range check
      redirect_to :controller => "import_legnose", :action => "simple_range_check"
    end
  end

  #riassunto errori derivari dai check compliance
  def comp_error_summary
    #carico il file
    @file = ImportFile.find(session[:file_id])
    #carico tutti gli errori compliance determinati da questa sessione
    #cioè tutti gli errori che corrispondono al numero di volte che è stato importato il file
    #ogni import ha i suoi errori, in base alla variabile import_num
    @comp_err = ErrorLegnose.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Compliance' ",session[:file_id],@file.import_num])
  end


  def simple_range_check
    #carico il file che sto analizzando
    file = ImportFile.find(session[:file_id])
    #caricol tutti i record temporanei del file attuale(cosiderando le volte che è stato importato) su cui effettuare i check
    rows = Legnose.find(:all, :conditions => ["temp = true AND file_name_id = ? AND import_num = ?",session[:file_id],file.import_num])
    #se non ci sono record da controllare
    if rows.blank?
      #non va bene, avverto
      flash[:error] = "Il file è vuoto"
      redirect_to :controller => "import_legnose"
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
        redirect_to :controller => "import_legnose", :action => "multiple_parameter_check"
      else
        flash[:error]="Controlla il report."
        redirect_to :controller => "import_legnose", :action => "sr_error_summary"
      end
    end
  end

  def sr_error_summary
    #carico il file
    @file = ImportFile.find(session[:file_id])
    #carico gli errori
    @sr_err = ErrorLegnose.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Simplerange' ",session[:file_id],@file.import_num])
  end

  def multiple_parameter_check
    #carico la campagna attiva
    open_camp = Campagne.find(:first,:conditions => ["active = true"])
    #carico il file che sto analizzando
    file = ImportFile.find(session[:file_id])
    #carico tutti i record temporanei del file attuale(cosiderando le volte che è stato importato) su cui effettuare i check
    rows = Legnose.find(:all, :conditions => ["temp = true AND file_name_id = ? AND import_num = ? AND campagne_id = ?",session[:file_id],file.import_num,open_camp.id])
    #setto gli errori mp a 0
    session[:mp_error] =  false
    #MP CHECK N.1
    all_subplot_100?
    #check su ogni record
    for i in 0..rows.size-1
      #MP CHECK N.2
      rad1_not_null(rows.at(i))
      #MP CHECK N.3
      rad2_not_null(rows.at(i))
      #MP CHECK N.4
      altezza_not_null(rows.at(i))
      #MP CHECK N.5
      specie_not_null(rows.at(i))
      #MP CHECK N.6
      cop0(rows.at(i))
    end

    #se non si è verificato nessun errore
    if session[:mp_error] == false
      #levo il flag di record temporaneo a tutti i record relativi a quest'import
      for i in 0..rows.size-1
        rows.at(i).permanent!
      end
      flash[:notice]="Complimenti nessun errore"
      redirect_to :controller => "import_legnose"
      #se si è verificato almeno 1 errore mostro il riepilogo degli errori
    elsif session[:mp_error] == true
      flash[:error]="Controlla il report."
      redirect_to :controller => "import_legnose", :action => "mp_error_summary"
    end
  end

  def mp_error_summary
    #carico il file
    @file = ImportFile.find(session[:file_id])
    #carico gli errori
    @mp_err = ErrorLegnose.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Multipleparameter' ",session[:file_id],@file.import_num])
    #carico gli errori globali
    @mp_gbe = ErrorLegnose.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Global Error' ",session[:file_id],@file.import_num])

  end

  private

  def multiple_parameter_error(record,error)
    #creo un nuovo errore
    @mp_error = ErrorLegnose.new
    #compilo l'errore
    @mp_error.fill_and_save_from_db(record,"Multipleparameter",error,session[:file_id])
    #segnalo che c'è stato un errore
    session[:mp_error] = true
  end

  #errore globale, ossia non dipendente da un record specifico
  def global_error(error,file)
    #creo un nuovo errore
    gb_e = ErrorLegnose.new
    #compilo l'errore globale
    gb_e.global_error_fill_and_save(error,file)
    #segnalo che c'è stato un errore
    session[:mp_error] = true
  end



  def simple_range_error(record,error)
    #creo un nuovo errore
    @sr_error = ErrorLegnose.new
    #compilo l'errore
    @sr_error.fill_and_save_from_db(record,"Simplerange",error,session[:file_id])
    #segnalo che c'è stato un errore
    session[:sr_error] = true
  end

  def save_error(record,error,row)
    @error = ErrorLegnose.new
    @error.fill_and_save_from_file(record,"Compliance",error,row,session[:file_id])
  end


end
