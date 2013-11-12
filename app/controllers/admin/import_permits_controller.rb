class Admin::ImportPermitsController < ApplicationController
  before_filter :login_required,:admin_authorization_required

  def index
    @year = Campagne.find_by_sql "SELECT DISTINCT anno FROM campagne WHERE deleted = false ORDER BY anno"
    @rilevatore = User.find(:all, :conditions => "approved = true AND user_kind_id IN (SELECT id FROM user_kinds WHERE kind = 'Rilevatore') AND id IN (SELECT rilevatore_id FROM sheet_file)")
  end

  def show_file
    @file = SheetFile.find(:all,:conditions => ["rilevatore_id = ? AND year = ?",params[:rilevatore],params[:year]])
    render :update do |page|
      page.show "file_list"
      page.replace_html "file_list", :partial => "schede", :object => @file
    end
  end

  def download_file
    @file = SheetFile.find(params[:id])
    send_file(@file.path, :filename => "#{@file.name}")
  end

  def create_permit
    file = SheetFile.find(params[:file_id])
    permit = ImportPermits.new
    permit.fill_and_save!(file.rilevatore_id,file.year,file.survey)
    #ricarico i file
    @file = SheetFile.find(:all,:conditions => ["rilevatore_id = ? AND year = ?",file.rilevatore_id,file.year])
    render :update do |page|
      page.replace_html "file_list", :partial => "schede", :object => @file
    end
    #SPEDIRE AVVISO VIA MAIL CHE IL PERMESSO E' STATO ASSEGNATO
    user = User.find(file.rilevatore_id)
    Notifier.deliver_add_import_permits(user,file.survey)
  end

  def delete_permit
    file = SheetFile.find(params[:file_id])
    permit = ImportPermits.find(:first,:conditions => ["rilevatore_id = ? AND year = ? AND survey = ?",file.rilevatore_id,file.year,file.survey])
    #ricarico i file
    @file = SheetFile.find(:all,:conditions => ["rilevatore_id = ? AND year = ?",file.rilevatore_id,file.year])
    #elimino il permesso
    permit.destroy
    render :update do |page|
      page.replace_html "file_list", :partial => "schede", :object => @file
    end
    #SPEDIRE AVVISO VIA MAIL CHE IL PERMESSO E' STATO RIMOSSO
    user = User.find(file.rilevatore_id)
    Notifier.deliver_remove_import_permits(user,file.survey)
  end

  def delete_file
    file = SheetFile.find(params[:file_id])
    #ricarico i file
    @file = SheetFile.find(:all,:conditions => ["rilevatore_id = ? AND year = ? AND id != ?",file.rilevatore_id,file.year,file.id])
    #SPEDIRE AVVISO VIA MAIL CHE IL FILE E' STATO RESPINTO E SI NECESSITA DI NUOVO L'UPLOAD
    user = User.find(file.rilevatore_id)
    Notifier.deliver_deleted_survey_sheet(user,file.survey)
    #elimino il file
    file.destroy
    render :update do |page|
      page.replace_html "file_list", :partial => "schede", :object => @file
    end

  end

end
