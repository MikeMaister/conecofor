class ImportErbaceeController < ApplicationController
  include Erb_checks,Import_survey

  before_filter :login_required,:rilevatore_authorization_required,:rilevatore_approvato
  before_filter :campaign_active?, :only => "index"
  before_filter [:session_reset!,:file?,:file_type?,:file_date_conformity?,
                 :set_file,:delete_old_record_cache!],
                :only => "import_procedure"
  before_filter :import_permit_erb?, :only => "import_procedure"



  def index
    @active_campaign = Campagne.find(:first, :conditions => ["active = true"])
  end

  def import_procedure
    begin
      result = compliance_check
      result = simple_range_check if result == 0
      result = multiple_parameter_check if result == 0
      #reindirizzo in base al risultato della procedura
      case result
        when 0
          set_permanent_data!("erb")
          flash[:notice] = "Complimenti nessun errore."
          redirect_to :action => "finish"
        when 1  #COMPLIANCE
          delete_temp_compliance!("erb")
          #faccio il redirect verso il riepilogo degli errori trovati
          flash[:error] = "Controlla il report."
          redirect_to :action => "comp_error_summary"
        when 2 #SIMPLE RANGE
          #faccio il redirect verso il riepilogo errori
          flash[:error]= " Controlla il report."
          redirect_to :action => "sr_error_summary"
        when 3 #MULTIPLE PARAMETER
          #faccio il redirect verso il riepilogo errori
          flash[:error]= "Controlla il report."
          redirect_to :action => "mp_error_summary"
        when 10
          flash[:error] = "Il file non contiene nessun dato."
          redirect_to :controller => "import_erbacee"
      end
    rescue
      flash[:error] = "Si è riscontrato un problema con il file. Aprire il file e salvarlo in formato .xls"
      redirect_to :controller => "import_erbacee"
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

  def sr_error_summary
    #carico il file
    @file = ImportFile.find(session[:file_id])
    #carico gli errori
    @sr_err = ErrorErbacee.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Simplerange' ",session[:file_id],@file.import_num])
    #carico gli errori di tipo warning
    @sr_warning = ErrorErbacee.find(:all,:select =>"DISTINCT specie,error",:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Warning' ",session[:file_id],@file.import_num])
  end

  def mp_error_summary
    #carico il file
    @file = ImportFile.find(session[:file_id])
    #carico gli errori
    @mp_err = ErrorErbacee.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Multipleparameter' ",session[:file_id],@file.import_num])
    #carico gli errori globali
    @mp_gbe = ErrorErbacee.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Global Error' ",session[:file_id],@file.import_num])
  end

  def force_input
    if session[:mp_error] == false
      #carico il file
      @file = ImportFile.find(session[:file_id])
      #carico gli errori globali
      @mp_gbe = ErrorErbacee.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Global Error' ",session[:file_id],@file.import_num])
      @mp_gbe.each do |gbe|
        gbe.force_it!
      end
      set_permanent_data!("erb")
      flash[:notice] = "Dati Forzati."
      redirect_to :action => "finish"
    else
      flash[:error] = "Qualcosa è andato storto, riprova."
      redirect_to :controller => "import_erbacee"
    end
  end

  def force_warning
    if session[:sr_error] == false && session[:sr_warning] == true
      #carico tutte le giustifiche
      @giustifiche = params[:giustifica]
      @speci = params[:specie]
      if all_giustifiche?(@giustifiche) == true
        #carico il file
        @file = ImportFile.find(session[:file_id])
        #carico gli errori di tipo warning
        @sr_warning = ErrorErbacee.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Warning' ",session[:file_id],@file.import_num])
        #per ogni errore carico il corrispondente record in cops
        for i in 0..@sr_warning.size-1
          erb_record = Erbacee.find(@sr_warning.at(i).erbacee_id)
          #salvo la stessa giustifica per tutti i record aventi la stessa specie
          for n in 0..@speci.size-1
            erb_record.set_habitual_note(@giustifiche.at(n)) if @speci.at(n) == erb_record.descrizione_pignatti
          end
          #forzo l'errore
          @sr_warning.at(i).force_it!
        end
        #continuo il controllo con gli mp_check
        result = multiple_parameter_check
        #reindirizzo in base al risultato della procedura
        case result
          when 0
            set_permanent_data!("erb")
            flash[:notice] = "Complimenti nessun errore."
            redirect_to :action => "finish"
          when 3 #MULTIPLE PARAMETER
            #faccio il redirect verso il riepilogo errori
            flash[:error]= "Controlla il report."
            redirect_to :action => "mp_error_summary"
        end
      else
        flash[:error] = "Compila tutte le giustifiche prima di procedere."
        redirect_to :action => "sr_error_summary"
      end
    end
  end

  def finish
    if session[:file_id].blank?
      redirect_to :controller => "import_erbacee"
    else
      @file = ImportFile.find(session[:file_id])
      #mando la mail di notifica
      Notifier.deliver_user_import_complete(current_user,@file)
      session_reset!
    end
  end

  private

  def all_giustifiche?(giustifiche)
    vuota = false
    for i in 0..giustifiche.size-1
      if giustifiche.at(i).blank?
        vuota = true
        break
      end
    end
    if vuota == false
      return true
      eslif vuota == true
      return false
    end
  end

  def compliance_check
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
    #chiudo il file [vedere riferimento import_cops]
    doc.io.close
    #ritorno 1 se ci sono stati errori di tipo compliance
    if session[:file_error] == true
      result = 1
    #0 altrimenti
    elsif session[:file_error] == false
      result = 0
    end
    return result
  end

  def save_error(record,error,row)
    @error = ErrorErbacee.new
    @error.fill_and_save_from_file(record,"Compliance",error,row+1,session[:file_id])
  end

  def simple_range_check
    #carico il file che sto analizzando
    file = ImportFile.find(session[:file_id])
    #caricol tutti i record temporanei del file attuale(cosiderando le volte che è stato importato) su cui effettuare i check
    rows = Erbacee.find(:all, :conditions => ["temp = true AND file_name_id = ? AND import_num = ?",session[:file_id],file.import_num])
    #se non ci sono record da controllare
    if rows.blank?
      result = 10
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
        #SR Check 2
        habitual_species(rows.at(i)) unless rows.at(i).specie_id.blank?
      end
      #controllo se ci sono errori simple range
      if session[:sr_error] == true || session[:sr_warning] == true
        result = 2
      elsif session[:sr_error] == false
        result = 0
      end
    end
    return result
  end

  def simple_range_error(record,error)
    #creo un nuovo errore
    @sr_error = ErrorErbacee.new
    #compilo l'errore
    @sr_error.fill_and_save_from_db(record,"Simplerange",error,session[:file_id])
    #segnalo che c'è stato un errore
    session[:sr_error] = true
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
    session[:mp_warning] = false
    #MP CHECK N.1
    all_subplot_100?
    #check su ogni record
    for i in 0..rows.size-1
      #MP CHECK N.2
      cop0_null(rows.at(i))
      #MP CHECK N.3
      hedera_helix_check(rows.at(i))
    end
    #controllo se ci sono stati errori
    if session[:mp_error] == true || session[:mp_warning] == true
      result = 3
    elsif session[:mp_error] == false && session[:mp_warning] == false
      result = 0
    end
    return result
  end

  def multiple_parameter_error(record,error)
    #creo un nuovo errore
    @mp_error = ErrorErbacee.new
    #compilo l'errore
    @mp_error.fill_and_save_from_db(record,"Multipleparameter",error,session[:file_id])
    #segnalo che c'è stato un errore
    session[:mp_error] = true
  end

  #errore globale, ossia non dipendente da un record specifico
  def global_error(error,file)
    #creo un nuovo errore
    gb_e = ErrorErbacee.new
    #compilo l'errore globale
    gb_e.global_error_fill_and_save(error,file)
    #segnalo che c'è stato un errore
    session[:mp_warning] = true
  end

  def warning_error(record,error,file)
    warning = ErrorErbacee.new
    warning.warnings_fill_and_save(record,error,file)
    session[:sr_warning] = true
  end

end

