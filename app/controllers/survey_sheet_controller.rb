class SurveySheetController < ApplicationController
  include Import_survey
  before_filter :login_required
  before_filter :rilevatore_authorization_required, :except => :download_survey_sheet
  before_filter :rilevatore_approvato, :except => :download_survey_sheet
  before_filter :campaign_active?
  before_filter :file? , :only => :import_file
  before_filter :valid_name_format?, :only => :import_file
  before_filter :valid_year?, :only => :import_file
  before_filter :valid_name_plot?, :only => :import_file
  before_filter :valid_survey?, :only => :import_file

  def index
    @active_campaign = current_active_campaign
    @loaded_file = SheetFile.find(:all,:conditions => ["rilevatore_id = ? AND campagna_id = ?",current_user.id,@active_campaign.id])
    @file_erb = SheetFile.find_by_sql ["select p.id_plot,name from (select id_plot from plot where deleted = false order by id_plot) as p
left join
(select id_plot,name from sheet_file,plot where plot_id = plot.id and survey = 'ERB' and campagna_id = ? and rilevatore_id = ?) as s
on p.id_plot = s.id_plot",@active_campaign.id,current_user.id]
    @file_leg = SheetFile.find_by_sql ["select p.id_plot,name from (select id_plot from plot where deleted = false order by id_plot) as p
left join
(select id_plot,name from sheet_file,plot where plot_id = plot.id and survey = 'LEG' and campagna_id = ? and rilevatore_id = ?) as s
on p.id_plot = s.id_plot",@active_campaign.id,current_user.id]
    @file_copl = SheetFile.find_by_sql ["select p.id_plot,name from (select id_plot from plot where deleted = false order by id_plot) as p
left join
(select id_plot,name from sheet_file,plot where plot_id = plot.id and survey = 'COPL' and campagna_id = ? and rilevatore_id = ?) as s
on p.id_plot = s.id_plot",@active_campaign.id,current_user.id]
    @file_cops = SheetFile.find_by_sql ["select p.id_plot,name from (select id_plot from plot where deleted = false order by id_plot) as p
left join
(select id_plot,name from sheet_file,plot where plot_id = plot.id and survey = 'COPS' and campagna_id = ? and rilevatore_id = ?) as s
on p.id_plot = s.id_plot",@active_campaign.id,current_user.id]

  end

  def import_file
    #carico il file nella directory e lo traccio nel db
    file = upload_save_file!(params[:upload])
    if file == false
      flash[:error] = "Il file caricato risulta essere presente nel sistema ed in attesa di approvazione. Nel caso in cui questa risulti essere un anomalia, contattare un admin CONECOFOR."
    else
      #spedisco la mail di notifica
      Notifier.deliver_user_survey_sheet(current_user,file)
      flash[:notice] = "Caricamento effettuato con successo."
    end
    redirect_to :action => "index"
  end

  before_filter :admin_authorization_required, :only => :download_survey_sheet
  def download_survey_sheet
    file = SheetFile.find(params[:id])
    rilevatore = User.find(file.rilevatore_id)
    send_file "#{RAILS_ROOT}/file privati app/schede rilevatori/#{rilevatore.full_name}/#{file.survey}/#{file.name}"
  end

  private

  def upload_save_file!(file)
    name = (file)['datafile'].original_filename
    #setto il plot
    plot = get_plot(name)
    #setto la survey
    survey = get_survey(name)
    #CAMBIARE LA DIRECTORY CON QUELLA DEL SERVER(non nella cartella public)
    #directory = "#{RAILS_ROOT}/public/schede_rilevatori/#{current_user.full_name}/#{survey}/"
    #relative_path = "schede_rilevatori/#{current_user.full_name}/#{survey}/" + name
    directory = "#{RAILS_ROOT}/file privati app/schede rilevatori/#{current_user.full_name}/#{current_active_campaign.descrizione}/#{plot.id_plot}/#{survey}/"
    relative_path = "schede rilevatori/#{current_user.full_name}/#{current_active_campaign.descrizione}/#{plot.id_plot}/#{survey}/" + name
    #creo la cartella
    require 'ftools'
    File.makedirs directory
    #create the file path
    path = File.join(directory, name)
    #write the file
    File.open(path, "wb") { |f| f.write(file['datafile'].read) }
    #traccio il file
    new_file = SheetFile.new
    new_file.fill!(current_user.id,name,survey,path,relative_path,plot.id,current_active_campaign.id)
    #se è già stato caricato un file per quel plot in quella campagna di quel rilevatore per quella survey
    if duplicate_file?(new_file) == true
      return false
    #altrimenti ritorno il file
    else
      #lo salvo e lo ritorno
      new_file.save
      return new_file
    end
  end

  #controllo che il file sia un pdf e che abbia la nomenclatura stabilita
  def valid_name_format?
    name = (params[:upload])['datafile'].original_filename
    formato = /^[S]{2}\d{6}[A-Z]{3}\d[A-Z]{3,4}[.][p][d][f]$/
    unless name =~ formato
      flash[:error] = "Formato o nome file non valido."
      redirect_to :back
    end
  end

  #controllo che il plot dichiarato nel nome del file esista nel db
  def valid_name_plot?
    name = (params[:upload])['datafile'].original_filename
    plot = get_plot(name)
    if plot.blank?
      flash[:error] = "Il plot indicato nel nome del file non esiste."
      redirect_to :action => "index"
    end
  end

  #controllo che il tipo di rilevamento indicato nel nome del file sia valido
  def valid_survey?
    name = (params[:upload])['datafile'].original_filename
    survey = get_survey(name)
    #a meno che il tipo di rilevamento sia tra quelli designati, segnalo l'errore
    unless survey == "ERB" || survey == "LEG" || survey == "COPL" || survey == "COPS"
      flash[:error] = "Il tipo di rilevamento indicato nel nome del file non è valido."
      redirect_to :action => "index"
    end
  end

  def valid_year?
    name = (params[:upload])['datafile'].original_filename
    year = name[2..5]
    if year.to_i != current_active_campaign.anno.to_i
      flash[:error] = "L'anno indicato nel nome del file non corrisponde a quello della campagna attiva."
      redirect_to :action => "index"
    end
  end

  def get_plot(file_name)
    id_plot = file_name[6..11]
    plot = Plot.find(:first,:conditions => ["id_plot = ? and deleted = false",id_plot])
  end

  def get_survey(file_name)
    #se il 15 carattere è un .
    if file_name[15..15] == "."
      #la survey può essere solo erb o leg quindi di 3 lettere
      survey = file_name[12..14]
    else
      #la survey può essere solo copl o cops quindi di 4 lettere
      survey = file_name[12..15]
    end
  end

  #controllo che il file non sia stato caricato 2 volte da qualsiasi rilevatore(NOTARE BENE).
  def duplicate_file?(file)
    duplicate = SheetFile.find(:first,:conditions => ["survey = ? and plot_id = ? and campagna_id = ?",file.survey,file.plot_id,file.campagna_id])
    if duplicate.blank?
      return false
    else
      return true
    end
  end

end
