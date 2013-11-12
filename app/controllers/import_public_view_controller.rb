class ImportPublicViewController < ApplicationController
  before_filter :login_required

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
        @import_data = Erbacee.find(:all, :conditions => ["plot_id = ? AND campagne_id = ? AND temp = 'false' AND approved = true",plot,campagna])
        @file = ImportFile.find(:first,:conditions => ["campagne_id = ? and survey_kind = 'Erb' and plot_number = ?",campagna,Plot.find(plot).numero_plot])
        render :update do |page|
          page.show "result"
          page.replace_html "result", :partial => 'table_erb', :object => [@import_data,@file]
        end
      when "Legn"
        @import_data = Legnose.find(:all, :conditions => ["plot_id = ? AND campagne_id = ? AND temp = 'false' AND approved = true",plot,campagna])
        @file = ImportFile.find(:first,:conditions => ["campagne_id = ? and survey_kind = 'Leg' and plot_number = ?",campagna,Plot.find(plot).numero_plot])
        render :update do |page|
          page.show "result"
          page.replace_html "result", :partial => 'table_legn', :object => [@import_data,@file]
        end
      when "Copl"
        @import_data = Copl.find(:all, :conditions => ["plot_id = ? AND campagne_id = ? AND temp = 'false' AND approved = true",plot,campagna])
        @file = ImportFile.find(:first,:conditions => ["campagne_id = ? and survey_kind = 'Copl' and plot_number = ?",campagna,Plot.find(plot).numero_plot])
        render :update do |page|
          page.show "result"
          page.replace_html "result", :partial => 'table_copl', :object => [@import_data,@file]
        end
      when "Cops"
        @import_data = Cops.find(:all, :conditions => ["plot_id = ? AND campagne_id = ? AND temp = 'false' AND approved = true AND deleted = false",plot,campagna])
        @file = ImportFile.find(:first,:conditions => ["campagne_id = ? and survey_kind = 'Cops' and plot_number = ?",campagna,Plot.find(plot).numero_plot])
        render :update do |page|
          page.show "result"
          page.replace_html "result", :partial => 'table_cops', :object => [@import_data,@file]
        end
    end

  end

end
