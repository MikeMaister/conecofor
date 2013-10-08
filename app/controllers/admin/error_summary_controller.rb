class Admin::ErrorSummaryController < ApplicationController

  def index
    id_rilevatore = UserKind.find(:first,:conditions => ["identifier = 2"]).id
    @rilevatore = User.find(:all,:conditions => ["user_kind_id = ?", id_rilevatore])
    @campagna = Campagne.find(:all,:conditions => ["deleted = false"])
    @plot = Plot.find(:all,:conditions => ["deleted = false"], :order => "id_plot")
  end

  def search
    id_rilevatore = params[:rilevatore]
    id_campagna = params[:campagna]
    id_plot = params[:plot]
    numero_plot = Plot.find(id_plot).numero_plot
    @file = ImportFile.find(:all, :conditions => ["user_id = ? AND campagne_id = ? AND plot_number = ? AND deleted = false",id_rilevatore,id_campagna,numero_plot ])

    render :update do |page|
      #nascondo i dettagli degli errori precedentemente selezionati
      page.show "showall"
      #page.hide "compliance"
      #page.hide "sre"
      #page.hide "mpe"
      #page.hide "ge"
      #mostro la nuova ricerca
      page.show "result"
      page.replace_html "result", :partial => "file_list", :object => @file
    end
  end

  def show_error

    @survey = params[:survey_kind]
    file_id = params[:file_id]
    @file_name = ImportFile.find(file_id).file_name

    case @survey
      when "Copl"
        @comp = ErrorCopl.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Compliance'",file_id])
        @sre = ErrorCopl.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Simplerange'",file_id])
        @mpe = ErrorCopl.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Multipleparameter'",file_id])
        @ge = ErrorCopl.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Global Error'",file_id])

        render :update do |page|
          page.show "current_file"
          page.replace_html "current_file", :partial => "file_name", :object => @file_name
          page.show "compliance"
          #page.replace_html "compliance", :partial => "copl_compliance_errors", :object => @comp
          page.replace_html "compliance", :partial => "copl_error", :object => @comp
          page.show "sre"
          #page.replace_html "sre", :partial => "copl_sre_errors", :object => @sre
          page.replace_html "sre", :partial => "copl_error", :object => @sre
          page.show "mpe"
          #page.replace_html "mpe", :partial => "copl_mpe_errors", :object => @mpe
          page.replace_html "mpe", :partial => "copl_error", :object => @mpe
          page.show "ge"
          page.replace_html "ge", :partial => "global_errors", :object => @ge
        end

      when "Cops"
        @comp = ErrorCops.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Compliance'",file_id])
        @sre = ErrorCops.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Simplerange'",file_id])
        @mpe = ErrorCops.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Multipleparameter'",file_id])
        @ge = ErrorCops.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Global Error'",file_id])

        render :update do |page|
          page.show "current_file"
          page.replace_html "current_file", :partial => "file_name", :object => @file_name
          page.show "compliance"
          #page.replace_html "compliance", :partial => "cops_compliance_errors", :object => @comp
          page.replace_html "compliance", :partial => "cops_error", :object => @comp
          page.show "sre"
          #page.replace_html "sre", :partial => "cops_sre_errors", :object => @sre
          page.replace_html "sre", :partial => "cops_error", :object => @sre
          page.show "mpe"
          #page.replace_html "mpe", :partial => "cops_mpe_errors", :object => @mpe
          page.replace_html "mpe", :partial => "cops_error", :object => @mpe
          page.show "ge"
          page.replace_html "ge", :partial => "global_errors", :object => @ge
        end

      when "Leg"
        @comp = ErrorLegnose.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Compliance'",file_id])
        @sre = ErrorLegnose.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Simplerange'",file_id])
        @mpe = ErrorLegnose.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Multipleparameter'",file_id])
        @ge = ErrorLegnose.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Global Error'",file_id])

        render :update do |page|
          page.show "current_file"
          page.replace_html "current_file", :partial => "file_name", :object => @file_name
          page.show "compliance"
          #page.replace_html "compliance", :partial => "legnose_compliance_errors", :object => @comp
          page.replace_html "compliance", :partial => "leg_error", :object => @comp
          page.show "sre"
          #page.replace_html "sre", :partial => "legnose_sre_errors", :object => @sre
          page.replace_html "sre", :partial => "leg_error", :object => @sre
          page.show "mpe"
          #page.replace_html "mpe", :partial => "legnose_mpe_errors", :object => @mpe
          page.replace_html "mpe", :partial => "leg_error", :object => @mpe
          page.show "ge"
          page.replace_html "ge", :partial => "global_errors", :object => @ge
        end

      when "Erb"
        @comp = ErrorErbacee.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Compliance'",file_id])
        @sre = ErrorErbacee.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Simplerange'",file_id])
        @mpe = ErrorErbacee.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Multipleparameter'",file_id])
        @ge = ErrorErbacee.find(:all,:conditions => ["file_name_id = ? AND error_kind = 'Global Error'",file_id])

        render :update do |page|
          page.show "current_file"
          page.replace_html "current_file", :partial => "file_name", :object => @file_name
          page.show "compliance"
          #page.replace_html "compliance", :partial => "erbacee_compliance_errors", :object => @comp
          page.replace_html "compliance", :partial => "erb_error", :object => @comp
          page.show "sre"
          #page.replace_html "sre", :partial => "erbacee_sre_errors", :object => @sre
          page.replace_html "sre", :partial => "erb_error", :object => @sre
          page.show "mpe"
          #page.replace_html "mpe", :partial => "erbacee_mpe_errors", :object => @mpe
          page.replace_html "mpe", :partial => "erb_error", :object => @mpe
          page.show "ge"
          page.replace_html "ge", :partial => "global_errors", :object => @ge
        end
    end




  end

  def update_campagne
    @camp = Campagne.find_by_sql ["SELECT * FROM campagne WHERE deleted = false AND id IN (SELECT campagne_id FROM import_file WHERE user_id = ? AND deleted = false)",params[:rilevatore_selezionato]]

    session[:rilevatore] = params[:rilevatore_selezionato]

    render :update do |page|
      page.show "select_camp"
      page.replace_html "select_camp", :partial => "select_campagne", :object => @camp
    end
  end

  def update_plot
    @plot = Plot.find_by_sql ["SELECT * FROM plot WHERE deleted = false AND numero_plot IN (SELECT plot_number FROM import_file WHERE campagne_id = ? AND user_id = ? AND deleted = false)",params[:campagna_selezionata],session[:rilevatore]]

    render :update do |page|
      page.show "select_plot"
      page.replace_html "select_plot", :partial => "select_plot", :object => @plot
    end
  end


end
