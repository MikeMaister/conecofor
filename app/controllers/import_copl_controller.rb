class ImportCoplController < ApplicationController
  include Copl_checks,Import_survey

  before_filter :campaign_active?, :only => "index"
  before_filter :import_permit_copl?
  before_filter [:session_reset!,:file?,:file_type?,:file_date_conformity?,
                 :set_file,:delete_old_record_cache!],
                :only => "import_procedure"


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
          set_permanent_data!("copl")
          #mando la mail di notifica
          Notifier.deliver_user_import_complete(current_user,"copl")
          flash[:notice] = "Complimenti nessun errore."
          redirect_to :action => "finish"
        when 1  #COMPLIANCE
          delete_temp_compliance!("copl")
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
          redirect_to :controller => "import_copl"
      end
    rescue
      flash[:error] = "Si è riscontrato un problema con il file. Aprire il file e salvarlo in formato .xls"
      redirect_to :controller => "import_copl"
    end
  end

  #riassunto errori derivari dai check compliance
  def comp_error_summary
    #carico il file
    @file = ImportFile.find(session[:file_id])
    #carico tutti gli errori compliance determinati da questa sessione
    #cioè tutti gli errori che corrispondono al numero di volte che è stato importato il file
    #ogni import ha i suoi errori, in base alla variabile import_num
    @comp_err = ErrorCopl.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Compliance' ",session[:file_id],@file.import_num])
  end

  def sr_error_summary
    #carico il file
    @file = ImportFile.find(session[:file_id])
    #carico gli errori
    @sr_err = ErrorCopl.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Simplerange' ",session[:file_id],@file.import_num])
  end

  def mp_error_summary
    #carico il file
    @file = ImportFile.find(session[:file_id])
    #carico gli errori
    @mp_err = ErrorCopl.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Multipleparameter' ",session[:file_id],@file.import_num])
    #carico gli errori globali
    @mp_gbe = ErrorCopl.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Global Error' ",session[:file_id],@file.import_num])

  end

  def force_input
    if session[:mp_error] == false
      #carico il file
      @file = ImportFile.find(session[:file_id])
      #carico gli errori globali
      @mp_gbe = ErrorCopl.find(:all,:conditions => ["file_name_id = ? AND import_num = ? AND error_kind = 'Global Error' ",session[:file_id],@file.import_num])
      @mp_gbe.each do |gbe|
        gbe.force_it!
      end
      set_permanent_data!("copl")
      flash[:notice] = "Dati Forzati."
      redirect_to :action => "finish"
    else
      flash[:error] = "Qualcosa è andato storto, riprova."
      redirect_to :controller => "import_copl"
    end
  end

  def finish
    if session[:file_id].blank?
      redirect_to :controller => "import_copl"
    else
      @file = ImportFile.find(session[:file_id])
      session_reset!
    end
  end

  private

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
      unless row[0].blank? && row[1].blank? && row[2].blank? && row[3].blank? && row[4].blank? && row[5].blank? && row[6].blank? && row[7].blank? && row[8].blank? && row[9].blank? && row[10].blank? && row[11].blank? && row[12].blank? && row[13].blank? && row[14].blank? && row[15].blank?
        #fa saltare la prima riga
        if i != 0
          #memorizzo il record temporaneo
          #CORRISPONDENZA ALLE COLONNE DEL FILE
          record = FileRowCopl.new(row[0],row[1],row[2],row[3],row[4],row[5],row[6],row[7],row[8],row[9],row[10],row[11],row[12],row[13],row[14],row[15])
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
                      compliance_row = Copl.new
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
    @error = ErrorCopl.new
    @error.fill_and_save_from_file(record,"Compliance",error,session[:file_id],row+1)
  end

  def simple_range_check
    #carico il file che sto analizzando
    file = ImportFile.find(session[:file_id])
    #carico tutti i record temporanei del file attuale(cosiderando le volte che è stato importato) su cui effettuare i check
    rows = Copl.find(:all, :conditions => ["temp = true AND file_name_id = ? AND import_num = ?",session[:file_id],file.import_num])
    #se non ci sono record da controllare
    if rows.blank?
      result = 10
      #altrimenti effettuo i check
    else
      #setto errori
      session[:sr_error] = false
      #scorro i record da controllare
      for i in (0..rows.size-1)
        #SR Check 1
        data_range(rows.at(i))
        #applico i src
        do_src_on_rows(rows.at(i),file.campagne_id)
      end
      #controllo se ci sono errori simple range
      if session[:sr_error] == true
        result = 2
      elsif session[:sr_error] == false
        result = 0
      end
    end
    return result
  end

  def simple_range_error(record,error)
    #creo un nuovo errore
    @sr_error = ErrorCopl.new
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
    rows = Copl.find(:all, :conditions => ["temp = true AND file_name_id = ? AND import_num = ? AND campagne_id = ?",session[:file_id],file.import_num,open_camp.id])
    #setto gli errori mp a 0
    session[:mp_error] =  false
    session[:mp_warning] = false
    #scorro i record da controllare
    for i in (0..rows.size-1)
      #MP check 1
      mc_cop_aae_alt_aae(rows.at(i))
    end
    #controllo gli errori globali
    #MP check 2
    all_subplot?
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
    @mp_error = ErrorCopl.new
    #compilo l'errore
    @mp_error.fill_and_save_from_db(record,"Multipleparameter",error,session[:file_id])
    #segnalo che c'è stato un errore
    session[:mp_error] = true
  end

  #errore globale, ossia non dipendente da un record specifico
  def global_error(error,file)
    #creo un nuovo errore
    gb_e = ErrorCopl.new
    #compilo l'errore globale
    gb_e.global_error_fill_and_save(error,file)
    #segnalo che c'è stato un errore
    session[:mp_warning] = true
  end

end
