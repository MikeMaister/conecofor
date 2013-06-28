class SurveySheetController < ApplicationController
  include Import_survey
  before_filter :campaign_active?
  before_filter :file? , :only => :import_file
  before_filter :pdf_file?, :only => :import_file
  before_filter :survey_blank?, :only => :import_file

  def index
  end

  def import_file
    #carico il file nella directory e lo traccio nel db
    upload_save_file!(params[:upload],params[:survey])
    #assegno i permessi di import per quel file
    permits = ImportPermits.new
    year = Campagne.find(:first,:conditions => "active = true").anno
    permits.fill_and_save!(current_user.id,year,params[:survey])
    flash[:notice] = "Caricamento effettuato con successo."
    redirect_to :action => "index"
  end

  private

  def survey_blank?
    if params[:survey].blank?
      flash[:error] = "Nessuna rilevazione selezionata."
      redirect_to :back
    end
  end

  def upload_save_file!(file,survey)
    name = (file)['datafile'].original_filename
    #CAMBIARE LA DIRECTORY CON QUELLA DEL SERVER(non nella cartella public)
    directory = "#{RAILS_ROOT}/public/schede_rilevatori/#{current_user.full_name}/#{survey}/"
    relative_path = "schede_rilevatori/#{current_user.full_name}/#{survey}/" + name
    #creo la cartella
    require 'ftools'
    File.makedirs directory
    #create the file path
    path = File.join(directory, name)
    #write the file
    File.open(path, "wb") { |f| f.write(file['datafile'].read) }
    year = Campagne.find(:first,:conditions => "active = true").anno
    #traccio il file nel db
    new_file = SheetFile.new
    new_file.fill_and_save!(current_user.id,name,survey,year,path,relative_path)
  end

  def pdf_file?
    name = (params[:upload])['datafile'].original_filename
    pdf = /[.][p][d][f]/
    unless name =~ pdf
      flash[:error] = "Formato file non valido."
      redirect_to :back
    end
  end

end
