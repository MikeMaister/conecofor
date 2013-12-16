module Import_survey

  private

  def get_plot_num(file_name,survey)
    number = file_name[6..7] if survey == "cops".upcase || survey == "copl".upcase
    number = file_name[5..6] if survey == "erb".upcase || survey == "leg".upcase
    return number
  end

  def import_permit_erb?
    permits = SheetFile.find(:all,:conditions => ["rilevatore_id = ? and campagna_id = ? and survey = ?",current_user.id,current_active_campaign.id,"ERB"])
    file_name = (params[:upload])['datafile'].original_filename
    plot_num = get_plot_num(file_name,"erb".upcase)
    #SECURITY REASON
    permesso = false
    permits.each do |p|
      if p.plot.numero_plot.to_i == plot_num.to_i
        permesso = true
        break
      end
    end
    if permesso == false
      flash[:error] = "Non hai il permesso per eseguire l'import del file #{file_name}. Controlla di aver caricato l'apposita scheda di rilevamento."
      redirect_to root_path
    end
  end

  def import_permit_leg?
    permits = SheetFile.find(:all,:conditions => ["rilevatore_id = ? and campagna_id = ? and survey = ?",current_user.id,current_active_campaign.id,"LEG"])
    file_name = (params[:upload])['datafile'].original_filename
    plot_num = get_plot_num(file_name,"leg".upcase)
    #SECURITY REASON
    permesso = false
    permits.each do |p|
      if p.plot.numero_plot.to_i == plot_num.to_i
        permesso = true
        break
      end
    end
    if permesso == false
      flash[:error] = "Non hai il permesso per eseguire l'import del file #{file_name}. Controlla di aver caricato l'apposita scheda di rilevamento."
      redirect_to root_path
    end
  end


  def import_permit_copl?
    permits = SheetFile.find(:all,:conditions => ["rilevatore_id = ? and campagna_id = ? and survey = ?",current_user.id,current_active_campaign.id,"COPL"])
    file_name = (params[:upload])['datafile'].original_filename
    plot_num = get_plot_num(file_name,"copl".upcase)
    #SECURITY REASON
    permesso = false
    permits.each do |p|
      if p.plot.numero_plot.to_i == plot_num.to_i
        permesso = true
        break
      end
    end
    if permesso == false
      flash[:error] = "Non hai il permesso per eseguire l'import del file #{file_name}. Controlla di aver caricato l'apposita scheda di rilevamento."
      redirect_to root_path
    end
  end


  def import_permit_cops?
    permits = SheetFile.find(:all,:conditions => ["rilevatore_id = ? and campagna_id = ? and survey = ?",current_user.id,current_active_campaign.id,"COPS"])
    file_name = (params[:upload])['datafile'].original_filename
    plot_num = get_plot_num(file_name,"cops".upcase)
    #SECURITY REASON
    permesso = false
    permits.each do |p|
      if p.plot.numero_plot.to_i == plot_num.to_i
        permesso = true
        break
      end
    end
    if permesso == false
      flash[:error] = "Non hai il permesso per eseguire l'import del file #{file_name}. Controlla di aver caricato l'apposita scheda di rilevamento."
      redirect_to root_path
    end
  end


  #controlla che ci sia almeno una campagna attiva
  def campaign_active?
    #cerco la campagna attiva
    active_campaign = Campagne.find(:first, :conditions => ["active = true"])
    #se non c'è
    if active_campaign.blank?
      flash[:error] = "Import non abilitato."
      redirect_to :back
    end
  end

  #controlla che sia stato selezionato un file
  def file?
    if params[:upload].blank?
      flash[:error] = "Nessun file selezionato."
      redirect_to :back
    end
  end

  #controlla che il tipo di file sia appropriato
  def file_type?
    unless valid_file_kind?(params[:upload],params[:survey])
      flash[:error] = "Tipo di file non valido."
      redirect_to :back
    end
  end

  #controlla il tipo di file e di rilevazione se sono tra quelli concordati
  def valid_file_kind?(file,survey)
    #prendo il nome
    name = (file)['datafile'].original_filename
    #imposto un file di tipo concordato .xls
    xls = /(\d+)(\D+)(\d+)[.][x][l][s]/
    #tipo di file (es. Cops, Copl, Erb, Leg)
    kind = /\d+(\D+)\d+[.]\S*/
    #estrapolo il tipo di file dal nome del file
    name =~ kind
    #memorizzo il tipo di rilevazione
    survey_kind = $1
    #se è un file di tipo concordato(Cops) .xls ritorno true
    true if name =~ xls && survey_kind.capitalize == survey.capitalize
  end

  def file_date_conformity?
    #rintraccio la campagna aperta
    open_camp = Campagne.find(:first, :conditions => ["active = true"])
    #se il nome del file non corrisponde alla campagna aperta
    if open_camp.inizio.year != year_from_file_name(params[:upload])
      flash[:error] = "L'anno del file non corrisponde all'anno della campagna predisposta all'import."
      redirect_to :back
    end
  end

  #ricava l'anno dal nome del file importato
  def year_from_file_name(file)
    #prendo il nome del file
    name = (file)['datafile'].original_filename
    #campagna 199X
    camp90 = /([9])(\d)\D+\d+[.]\S*/
    #campagna 20XX in avanti
    camp00 = /(\d+)\D+\d+[.]\S*/
    #se il file si riferisce alle campagne dal 1990 al 1999
    if name =~ camp90
      #anno = 19 + numeri rimanenti
      anno = "19" + $1 + $2
      #se il file si riferisce alle campagne dal 2000 al 2099
    elsif name =~ camp00
      #anno = 20 + numeri rimanenti
      anno = "20" + $1
    end
    anno = anno.to_i
  end

  def set_file
    #rintraccio la campagna aperta
    open_camp = Campagne.find(:first, :conditions => ["active = true"])
    #carico la maschera d'obbligatorietà nella sessione
    session[:mask_name] = MandatoryMask.find(MandatoryMaskAssociation.find(:first,:conditions => ["campagna_id = ?",open_camp.id]).mandatory_mask_id).mask_name
    #cerco il file che si vuole importare
    #prendo il nome
    file_name = (params[:upload])['datafile'].original_filename
    #cerco il file nel db
    file = ImportFile.find(:first,:conditions => ["file_name = ? AND campagne_id = ? AND deleted = false",file_name,open_camp.id])
    #se non è mai stato importato un file con quel nome
    if file.blank?
      #upload del file + traccia nel db
      upload_save_file!(params[:upload],open_camp,params[:survey].capitalize)
    else
      #controllo chi l'ha importato
      #chi sta importando il file ora, è lo stesso che lo ha importato la prima volta?
      if file.user_id == current_user.id
        #lo aggiorno
        update_file!(params[:upload],open_camp,params[:survey].capitalize)
      #se non è lo stesso user
      else
        #segnalo l'errore
        flash[:error] = "Il file denominato #{file_name} è stato importato da un altro utente.
                         Se questa risulta essere un anomalia, contattare un admin CONECOFOR."
        redirect_to :back
      end
    end
  end

  #controlla se un file è già stato importato
  def imported_file?(file,camp)
    #prendo il nome
    file_name = (file)['datafile'].original_filename
    #cerco il file nel db
    processed = ImportFile.find(:first,:conditions => ["file_name = ? AND campagne_id = ? AND deleted = false",file_name,camp.id])
    #se lo trovo ritorno true
    true if processed
  end

  #metodo che aggiorna i file in import dei rilevatori
  def update_file!(file,camp,survey)
    name = (file)['datafile'].original_filename
    #CAMBIARE LA DIRECTORY CON QUELLA DEL SERVER(non nella cartella public)
    #directory = "#{RAILS_ROOT}/public/file_importati/#{survey}/#{Season.find(camp.season_id).nome}"
    directory = "#{RAILS_ROOT}/file privati app/import/#{survey}/#{Season.find(camp.season_id).nome}"
    #create the file path
    path = File.join(directory, name)
    #write the file
    File.open(path, "wb") { |f| f.write(file['datafile'].read) }
    #rintraccio il file nel db
    file_db = ImportFile.find(:first,:conditions => ["file_name = ? AND campagne_id = ? AND deleted = false",name,camp.id])
    #aggiorno i parametri del file
    file_db.update_and_save
    #salvo l'id del file in sessione
    session[:file_id] = file_db.id
  end

  #metodo che fa l'upload dei file in import dei rilevatori e li traccia nel db
  def upload_save_file!(file,camp,survey)
    name = (file)['datafile'].original_filename
    #CAMBIARE LA DIRECTORY CON QUELLA DEL SERVER(non nella cartella public)
    #directory = "#{RAILS_ROOT}/public/file_importati/#{survey}/#{Season.find(camp.season_id).nome}"
    #relative_path = "/file_importati/#{survey}/#{Season.find(camp.season_id).nome}/" + name
    directory = "#{RAILS_ROOT}/file privati app/import/#{survey}/#{Season.find(camp.season_id).nome}"
    relative_path = "/import/#{survey}/#{Season.find(camp.season_id).nome}/" + name
    #creo la cartella
    require 'ftools'
    File.makedirs directory
    #create the file path
    path = File.join(directory, name)
    #write the file
    File.open(path, "wb") { |f| f.write(file['datafile'].read) }
    #traccio il file nel db
    new_file = ImportFile.new
    new_file.fill_and_save(name,camp.id,path,survey,current_user.id,plot_number_from_file_name(name),relative_path)
    #ora che il file è salvato il nome del file diventa variabile di sessione
    session[:file_id] = new_file.id
  end

  #serve se ci sono Simple Range Error
  #cancella i vecchi record provenienti da import incompleti
  def delete_old_record_cache!
    survey = params[:survey]
    active_campaign = Campagne.find(:first, :conditions => ["active = true"])
    file = ImportFile.find(:first,:conditions => ["campagne_id = ? AND survey_kind = ? ",active_campaign.id,survey.capitalize])
    case survey
      when "leg"
        if file
          #cancello tutti i record relativi ai vecchi import [NON I RECORD APPROVATI]
          Legnose.connection.execute("DELETE FROM legnose WHERE file_name_id = #{file.id} AND import_num < #{file.import_num} AND approved = false")
        end
      when "cops"
        if file
          #cancello tutti i record relativi ai vecchi import [NON I RECORD APPROVATI]
          Cops.connection.execute("DELETE FROM cops WHERE file_name_id = #{file.id} AND import_num < #{file.import_num} AND approved = false")
        end
      when "copl"
        if file
          #cancello tutti i record relativi ai vecchi import [NON I RECORD APPROVATI]
          Copl.connection.execute("DELETE FROM copl WHERE file_name_id = #{file.id} AND import_num < #{file.import_num} AND approved = false")
        end
      when "erb"
        if file
          #cancello tutti i record relativi ai vecchi import [NON I RECORD APPROVATI]
          Erbacee.connection.execute("DELETE FROM erbacee WHERE file_name_id = #{file.id} AND import_num < #{file.import_num} AND approved = false")
        end
    end
  end

  def delete_temp_compliance!(survey)
    #carico il file che sto analizzando
    file = ImportFile.find(session[:file_id])
    case survey
      when "cops"
        #cancello in cops tutti i record temporanei memorizzati (cancello la cache per gli altri check)
        Cops.connection.execute("DELETE FROM cops WHERE temp = true AND file_name_id = #{session[:file_id]} AND import_num = #{file.import_num}")
      when "copl"
        #cancello in cops tutti i record temporanei memorizzati (cancello la cache per gli altri check)
        Copl.connection.execute("DELETE FROM copl WHERE temp = true AND file_name_id = #{session[:file_id]} AND import_num = #{file.import_num}")
      when "erb"
        #cancello in legnose tutti i record temporanei memorizzati (cancello la cache per gli altri check)
        Erbacee.connection.execute("DELETE FROM erbacee WHERE temp = true AND file_name_id = #{session[:file_id]} AND import_num = #{file.import_num}")
      when "leg"
        #cancello in legnose tutti i record temporanei memorizzati (cancello la cache per gli altri check)
        Legnose.connection.execute("DELETE FROM legnose WHERE temp = true AND file_name_id = #{session[:file_id]} AND import_num = #{file.import_num}")
    end
  end

  def set_permanent_data!(survey)
    #carico la campagna attiva
    open_camp = Campagne.find(:first,:conditions => ["active = true"])
    #carico il file che sto analizzando
    file = ImportFile.find(session[:file_id])
    case survey
      when "cops"
        #carico tutti i record temporanei del file attuale(cosiderando le volte che è stato importato) su cui effettuare i check
        rows = Cops.find(:all, :conditions => ["temp = true AND file_name_id = ? AND import_num = ? AND campagne_id = ?",session[:file_id],file.import_num,open_camp.id])
      when "copl"
        #carico tutti i record temporanei del file attuale(cosiderando le volte che è stato importato) su cui effettuare i check
        rows = Copl.find(:all, :conditions => ["temp = true AND file_name_id = ? AND import_num = ? AND campagne_id = ?",session[:file_id],file.import_num,open_camp.id])
      when "erb"
        #carico tutti i record temporanei del file attuale(cosiderando le volte che è stato importato) su cui effettuare i check
        rows = Erbacee.find(:all, :conditions => ["temp = true AND file_name_id = ? AND import_num = ? AND campagne_id = ?",session[:file_id],file.import_num,open_camp.id])
      when "leg"
        #carico tutti i record temporanei del file attuale(cosiderando le volte che è stato importato) su cui effettuare i check
        rows = Legnose.find(:all, :conditions => ["temp = true AND file_name_id = ? AND import_num = ? AND campagne_id = ?",session[:file_id],file.import_num,open_camp.id])
    end
    #levo il flag di record temporaneo a tutti i record relativi a quest'import
    for i in 0..rows.size-1
      rows.at(i).permanent!
    end
  end

  #controlla se il check è obbligatorio
  def mandatory?(mask_name,survey,parameter)
    camp_id = Campagne.find(:first, :conditions => ["active = true"]).id
    mandatory = MandatoryMaskAssociation.find(:first, :conditions => ["campagna_id = ? AND deleted = false AND mandatory_mask_id IN (SELECT id FROM mandatory_mask WHERE mask_name = ? AND survey = ? AND parameter = ? AND deleted = false)",camp_id,mask_name,survey,parameter])
    return true if mandatory
  end

  #estrapolo il numero del plot dal nome del file
  def plot_number_from_file_name(file_name)
    #numero del plot
    plot_number = /\d+\D+(\d+)[.]\S*/
    #confronto
    file_name =~ plot_number
    #estrapolo il numero del plot
    file_plot = $1
    return file_plot = file_plot.to_i
  end

  #resetta tutte le variabili di sessione per l'import di un file
  def session_reset!
    session[:file_id] = nil
    session[:row_error] = nil
    session[:file_error] = nil
    session[:sr_error] = nil
    session[:sr_warning] = nil
    session[:mp_error] = nil
    session[:mp_warning] = nil
    session[:mask_name] = nil
  end

end