class Admin::PlotController < ApplicationController

  def index
    @plot = Plot.find(:all,:conditions => ["deleted = false"], :order => :numero_plot)
  end

  def new
    @new_plot = Plot.new
    #apro una finestra di input
    render :update do |page|
      page.show "new_plot"
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

end
