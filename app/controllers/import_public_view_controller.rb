class ImportPublicViewController < ApplicationController
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
        render :update do |page|
          page.show "result"
          page.replace_html "result", :partial => 'table_erb', :object => @import_data
        end
      when "Legn"
        @import_data = Legnose.find(:all, :conditions => ["plot_id = ? AND campagne_id = ? AND temp = 'false' AND approved = true",plot,campagna])
        render :update do |page|
          page.show "result"
          page.replace_html "result", :partial => 'table_legn', :object => @import_data
        end
      when "Copl"
        @import_data = Copl.find(:all, :conditions => ["plot_id = ? AND campagne_id = ? AND temp = 'false' AND approved = true",plot,campagna])
        render :update do |page|
          page.show "result"
          page.replace_html "result", :partial => 'table_copl', :object => @import_data
        end
      when "Cops"
        @import_data = Cops.find(:all, :conditions => ["plot_id = ? AND campagne_id = ? AND temp = 'false' AND approved = true AND deleted = false",plot,campagna])
        render :update do |page|
          page.show "result"
          page.replace_html "result", :partial => 'table_cops', :object => @import_data
        end
    end

  end

end
