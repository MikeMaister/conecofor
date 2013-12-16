class Admin::ImportPermitsController < ApplicationController
  before_filter :login_required,:admin_authorization_required

  def index
    @campagne = Campagne.find(:all,:conditions => ["deleted = false"],:order => "descrizione desc")
  end

  def load_rilev
    @rilevatore = User.find(:all, :conditions => ["approved = true AND user_kind_id IN (SELECT id FROM user_kinds WHERE kind = 'Rilevatore') AND id IN (SELECT rilevatore_id FROM sheet_file where campagna_id = ?)",params[:camp_id]])
    render :update do |page|
      page.show "load_rilev"
      page.replace_html "load_rilev",:partial => "rilevatori", :object => @rilevatore
    end
  end

  def show_file
    if params[:campagna].blank? || params[:rilevatore].blank?
      render :update do |page|
        page.hide "file_list"
        page.show "no_data"
      end
    else
      #carico i dati
      @file_erb,@file_leg,@file_copl,@file_cops = load_file_data(params[:campagna],params[:rilevatore])
      render :update do |page|
        page.hide "no_data"
        page.show "file_list"
        page.replace_html "tab_content", :partial => "schede", :object => [@file_erb,@file_leg,@file_copl,@file_cops]
      end
    end
  end

  def download_file
    @file = SheetFile.find(params[:id])
    send_file(@file.path, :filename => "#{@file.name}")
  end

  def create_permit
    file = SheetFile.find(params[:file_id])
    file.update_attribute(:import_permit,true)
    #ricarico i file
    @file_erb,@file_leg,@file_copl,@file_cops = load_file_data(file.campagna_id,file.rilevatore_id)
    render :update do |page|
      page.replace_html "tab_content", :partial => "schede", :object => [@file_erb,@file_leg,@file_copl,@file_cops]
    end
    #SPEDIRE AVVISO VIA MAIL CHE IL PERMESSO E' STATO ASSEGNATO
    user = User.find(file.rilevatore_id)
    Notifier.deliver_add_import_permits(user,file.name)
  end

  def delete_permit
    file = SheetFile.find(params[:file_id])
    file.update_attribute(:import_permit,false)
    #ricarico i file
    @file_erb,@file_leg,@file_copl,@file_cops = load_file_data(file.campagna_id,file.rilevatore_id)
    render :update do |page|
      page.replace_html "tab_content", :partial => "schede", :object => [@file_erb,@file_leg,@file_copl,@file_cops]
    end
    #SPEDIRE AVVISO VIA MAIL CHE IL PERMESSO E' STATO RIMOSSO
    user = User.find(file.rilevatore_id)
    Notifier.deliver_remove_import_permits(user,file.name)
  end

  def delete_file
    file = SheetFile.find(params[:file_id])
    campagna = file.campagna_id
    rilevatore = file.rilevatore_id
    name = file.name
    #elimino il file
    file.destroy
    #ricarico i file
    @file_erb,@file_leg,@file_copl,@file_cops = load_file_data(campagna,rilevatore)
    #SPEDIRE AVVISO VIA MAIL CHE IL FILE E' STATO RESPINTO E SI NECESSITA DI NUOVO L'UPLOAD
    user = User.find(rilevatore)
    Notifier.deliver_deleted_survey_sheet(user,name)
    render :update do |page|
      page.replace_html "tab_content", :partial => "schede", :object => [@file_erb,@file_leg,@file_copl,@file_cops]
    end
  end

  private

  def load_file_data(campagna,rilevatore)
    file_erb = SheetFile.find_by_sql ["select p.id_plot,name,s.id,import_permit from (select id_plot from plot where deleted = false order by id_plot) as p
left join
(select id_plot,name,sheet_file.id,import_permit from sheet_file,plot where plot_id = plot.id and survey = 'ERB' and campagna_id = ? and rilevatore_id = ?) as s
on p.id_plot = s.id_plot",campagna,rilevatore]
    file_leg = SheetFile.find_by_sql ["select p.id_plot,name,s.id,import_permit from (select id_plot from plot where deleted = false order by id_plot) as p
left join
(select id_plot,name,sheet_file.id,import_permit from sheet_file,plot where plot_id = plot.id and survey = 'LEG' and campagna_id = ? and rilevatore_id = ?) as s
on p.id_plot = s.id_plot",campagna,rilevatore]
    file_copl = SheetFile.find_by_sql ["select p.id_plot,name,s.id,import_permit from (select id_plot from plot where deleted = false order by id_plot) as p
left join
(select id_plot,name,sheet_file.id,import_permit from sheet_file,plot where plot_id = plot.id and survey = 'COPL' and campagna_id = ? and rilevatore_id = ?) as s
on p.id_plot = s.id_plot",campagna,rilevatore]
    file_cops = SheetFile.find_by_sql ["select p.id_plot,name,s.id,import_permit from (select id_plot from plot where deleted = false order by id_plot) as p
left join
(select id_plot,name,sheet_file.id,import_permit from sheet_file,plot where plot_id = plot.id and survey = 'COPS' and campagna_id = ? and rilevatore_id = ?) as s
on p.id_plot = s.id_plot",campagna,rilevatore]
   return file_erb,file_leg,file_copl,file_cops
  end


end
