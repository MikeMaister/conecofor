class ProvaController < ApplicationController
  def index
    @new_plot = Plot.new
    @mandatory = mandatory?("Prova","Cops","copertura_specifica",2)
  end

  def save_plot
    @new_plot = Plot.new
    #@new_plot.fill(params[:plot][:id_plot],params[:plot][:descrizione],88,params[:plot][:latitudine],params[:plot][:longitudine],params[:plot][:altitudine],params[:plot][:note])
    @new_plot.id_plot = params[:id_plot]
    @new_plot.descrizione = params[:descrizione]
    @new_plot.latitudine = params[:latitudine]
    @new_plot.longitudine = params[:longitudine]
    @new_plot.altitudine = params[:altitudine]
    @new_plot.note = params[:note]
    if @new_plot.save
      render :update do |page|
        page.replace_html "p1" , :partial => "prova/hello"
      end
    else
      render :update do |page|
        page.replace_html "p1" , :partial => "admin/plot/input_errors", :object => @new_plot
      end
    end
  end

end
