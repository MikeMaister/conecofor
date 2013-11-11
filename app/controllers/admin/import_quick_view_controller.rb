class Admin::ImportQuickViewController < ApplicationController
  def index
    @campaign = Campagne.find(:all,:conditions => ["deleted = false"], :order => "inizio DESC")
    @plot = Plot.find(:all,:conditions => ["deleted = false"], :order => "id_plot")
  end

  def search
    campagna = params[:campaign]
    plot = params[:plot]
    survey = params[:survey]

    case survey
      when "Erb"
        @import_data = Erbacee.find(:all, :conditions => ["plot_id = ? AND campagne_id = ? AND temp = 'false'",plot,campagna])
        render :update do |page|
          page.show "result"
          page.replace_html "result", :partial => 'table_erb', :object => @import_data
        end
      when "Legn"
        @import_data = Legnose.find(:all, :conditions => ["plot_id = ? AND campagne_id = ? AND temp = 'false'",plot,campagna])
        render :update do |page|
          page.show "result"
          page.replace_html "result", :partial => 'table_legn', :object => @import_data
        end
      when "Copl"
        @import_data = Copl.find(:all, :conditions => ["plot_id = ? AND campagne_id = ? AND temp = 'false'",plot,campagna])
        render :update do |page|
          page.show "result"
          page.replace_html "result", :partial => 'table_copl', :object => @import_data
        end
      when "Cops"
        @import_data = Cops.find(:all, :conditions => ["plot_id = ? AND campagne_id = ? AND temp = 'false' AND deleted = false",plot,campagna])
        render :update do |page|
          page.show "result"
          page.replace_html "result", :partial => 'table_cops', :object => @import_data
        end
    end
  end

  def approve
    survey_kind = params[:class]
    id_to_approve = params[:records]
    user = nil
    case survey_kind
      when "Copl"
        for i in 0..id_to_approve.size-1
          record_to_approve = Copl.find(id_to_approve.at(i))
          user = User.find(ImportFile.find(record_to_approve.file_name_id).user_id) if user.blank?
          record_to_approve.approve_it!
        end
        #spedisco la mail di notifica
        Notifier.deliver_approve_import(user,survey_kind)
        flash[:notice] = "Record Approvati"
        redirect_to :controller => "admin/import_quick_view"
      when "Cops"
        for i in 0..id_to_approve.size-1
          record_to_approve = Cops.find(id_to_approve.at(i))
          user = User.find(ImportFile.find(record_to_approve.file_name_id).user_id) if user.blank?
          record_to_approve.approve_it!
        end
        #spedisco la mail di notifica
        Notifier.deliver_approve_import(user,survey_kind)
        flash[:notice] = "Record Approvati"
        redirect_to :controller => "admin/import_quick_view"
      when "Erbacee"
        for i in 0..id_to_approve.size-1
          record_to_approve = Erbacee.find(id_to_approve.at(i))
          user = User.find(ImportFile.find(record_to_approve.file_name_id).user_id) if user.blank?
          record_to_approve.approve_it!
        end
        #spedisco la mail di notifica
        Notifier.deliver_approve_import(user,survey_kind)
        flash[:notice] = "Record Approvati"
        redirect_to :controller => "admin/import_quick_view"
      when "Legnose"
        for i in 0..id_to_approve.size-1
          record_to_approve = Legnose.find(id_to_approve.at(i))
          user = User.find(ImportFile.find(record_to_approve.file_name_id).user_id) if user.blank?
          record_to_approve.approve_it!
        end
        #spedisco la mail di notifica
        Notifier.deliver_approve_import(user,survey_kind)
        flash[:notice] = "Record Approvati"
        redirect_to :controller => "admin/import_quick_view"
      end
  end

  def delete
    survey_kind = params[:class]
    id_to_approve = params[:records]
    user = nil
    case survey_kind
      when "Copl"
        for i in 0..id_to_approve.size-1
          record_to_approve = Copl.find(id_to_approve.at(i))
          user = User.find(ImportFile.find(record_to_approve.file_name_id).user_id) if user.blank?
          record_to_approve.destroy
        end
        #spedisco la mail di notifica
        Notifier.deliver_deleted_import(user,survey_kind)
        flash[:notice] = "Record Eliminati"
        redirect_to :controller => "admin/import_quick_view"
      when "Cops"
        for i in 0..id_to_approve.size-1
          record_to_approve = Cops.find(id_to_approve.at(i))
          user = User.find(ImportFile.find(record_to_approve.file_name_id).user_id) if user.blank?
          record_to_approve.destroy
        end
        #spedisco la mail di notifica
        Notifier.deliver_deleted_import(user,survey_kind)
        flash[:notice] = "Record Eliminati"
        redirect_to :controller => "admin/import_quick_view"
      when "Erbacee"
        for i in 0..id_to_approve.size-1
          record_to_approve = Erbacee.find(id_to_approve.at(i))
          user = User.find(ImportFile.find(record_to_approve.file_name_id).user_id) if user.blank?
          record_to_approve.destroy
        end
        #spedisco la mail di notifica
        Notifier.deliver_deleted_import(user,survey_kind)
        flash[:notice] = "Record Eliminati"
        redirect_to :controller => "admin/import_quick_view"
      when "Legnose"
        for i in 0..id_to_approve.size-1
          record_to_approve = Legnose.find(id_to_approve.at(i))
          user = User.find(ImportFile.find(record_to_approve.file_name_id).user_id) if user.blank?
          record_to_approve.destroy
        end
        #spedisco la mail di notifica
        Notifier.deliver_deleted_import(user,survey_kind)
        flash[:notice] = "Record Eliminati"
        redirect_to :controller => "admin/import_quick_view"
    end
  end

end
