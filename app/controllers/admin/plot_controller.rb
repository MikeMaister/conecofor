class Admin::PlotController < ApplicationController

  def index
    @plot = Plot.find(:all,:conditions => ["deleted = false"], :order => :numero_plot)
  end

  def new
    @new_plot = Plot.new
    @plot = Plot.find(:all,:conditions => ["deleted = false"], :order => :numero_plot)
    #apro una finestra di input
    render :update do |page|
      page.hide "display_input_errors"
      page.show "new_plot"
      page.replace_html "plot_list", :partial => "plot_list", :object => @plot
      page.replace_html 'new_plot', :partial => 'new_plot_form', :object => @new_plot
    end
  end

  def save_plot
    #compilo i campi del nuovo plot
    @new_plot = Plot.new(params[:plot])
    #ricavo il numero del plot
    @new_plot.set_num_plot

    #se riesco a salvare il plot passando tutte le restrizioni
    if @new_plot.save
      #carico nuovamente i plot
      @plot = Plot.find(:all,:conditions => ["deleted = false"], :order => :numero_plot)
      #aggiorno la tabella dei plot e chiudo la maschera di input
      @message = "Nuovo Plot aggiunto."
      render :update do |page|
        page.hide "display_input_errors"
        page.hide "new_plot"
        page.replace_html "plot_list", :partial => "plot_list", :object => [@plot,@message]
      end
    else
      #mostro gli errori sull'input
      render :update do |page|
        page.show "display_input_errors"
        page.replace_html "display_input_errors", :partial => "input_errors", :object => @new_plot
      end
    end

  end

  def close_new_plot
    #chiudo gli errori sull'input e il nuovo input
    render :update do |page|
      page.hide "new_plot"
      page.hide "display_input_errors"
    end
  end

  def delete
    plot_to_delete = Plot.find(params[:id])
    plot_to_delete.delete_it!
    @plot = Plot.find(:all,:conditions => ["deleted = false"], :order => :numero_plot)
    @message = "Plot Eliminato."
    render :update do |page|
      page.replace_html "plot_list", :partial => "plot_list", :object => [:@plot,@message]
    end
  end

  def edit
    @id = params[:id]
    @i = params[:i]
    #ricarico i plot
    @plot = Plot.find(:all,:conditions => ["deleted = false"], :order => :numero_plot)
    render :update do |page|
      page.hide "new_plot"
      page.hide "display_input_errors"
      page.replace_html "plot_list", :partial => "edit_plot", :object => [:@id,@i,@plot]
    end
  end

  def close_edit
    #ricarico i plot
    @plot = Plot.find(:all,:conditions => ["deleted = false"], :order => :numero_plot)
    render :update do |page|
      page.hide "display_input_errors"
      page.replace_html "plot_list", :partial => "plot_list", :object => @plot
    end
  end

  def save_edit
    @new_plot = Plot.find(params[:id])
    if @new_plot.set_lat_long_alt(params[:latitudine],params[:longitudine],params[:altitudine])
      @plot = Plot.find(:all,:conditions => ["deleted = false"], :order => :numero_plot)
      @message = "Modifica salvata."
      render :update do |page|
        page.hide "display_input_errors"
        page.replace_html "plot_list", :partial => "plot_list", :object => [@plot,@message]
      end
    else
      @plot = Plot.find(:all,:conditions => ["deleted = false"], :order => :numero_plot)
      render :update do |page|
        page.show "display_input_errors"
        page.replace_html "display_input_errors", :partial => "input_errors", :object => @new_plot
      end
    end
  end

  def accessory_info
    @plot = Plot.find(:all,:conditions => "deleted = false", :order => "id_plot")
  end

  def attach_file
    if params[:plot].blank? || params[:upload].blank?
      flash[:error] = "Nessun file o plot selezionato."
      redirect_to :controller => "admin/plot",:action => "accessory_info"
    else
      import_file(params[:upload],params[:desc],params[:plot])
      plot = Plot.find(params[:plot])
      flash[:notice] = "Nuovo file aggiunto per il plot #{plot.id_plot}."
      redirect_to :controller => "admin/plot",:action => "accessory_info"
    end
  end

  def search_file
    @file_list = PlotFile.find(:all,:conditions => ["plot_id = ?",params[:plot_file]])
    if @file_list.blank?
      @message_error = "Nessun file presente."
      render :update do |page|
        page.show "error"
        page.replace_html "error", :partial => "layouts/remote_flash_message", :object => @message_error
        page.replace_html "file_list", ""
      end
    else
      render :update do |page|
        page.hide "error"
        page.replace_html "file_list", :partial => "file_list", :object => @file_list
      end
    end
  end


  private

  def import_file(file,desc,plot)
    name = (file)['datafile'].original_filename
    id_plot = Plot.find(plot).id_plot
    #CAMBIARE LA DIRECTORY CON QUELLA DEL SERVER(non nella cartella public)
    directory = "#{RAILS_ROOT}/public/file_accessori_plot/#{id_plot}"
    relative_path = "/file_accessori_plot/#{id_plot}/" + name
    #creo la cartella
    require 'ftools'
    File.makedirs directory
    #create the file path
    path = File.join(directory, name)
    #write the file
    File.open(path, "wb") { |f| f.write(file['datafile'].read) }
    #traccio il file nel db
    new_file = PlotFile.new
    new_file.fill_and_save!(name,path,relative_path,desc,plot)
  end

end
