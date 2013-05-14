class Admin::EufloraController < ApplicationController

  def index
    @euflora = Euflora.find(:all,:order => "codice_eu")
  end

  def new
    @new_euflora = Euflora.new
    @euflora = Euflora.find(:all,:order => "codice_eu")
    @spe_vs = SpecieVs.find(:all, :order => "listspe")
    #apro una finestra di input
    render :update do |page|
      page.hide "display_input_errors"
      page.show "new_euflora"
      page.replace_html "euflora_list", :partial => "eu_list", :object => @euflora
      page.replace_html 'new_euflora', :partial => 'new_euflora_form', :object => [@new_euflora,@spe_vs]
    end
  end

  def close_new_euflora
    #chiudo gli errori sull'input e il nuovo input
    render :update do |page|
      page.hide "new_euflora"
      page.hide "display_input_errors"
    end
  end

  def save_eu
    #compilo i campi del nuovo plot
    @new_euflora = Euflora.new(params[:euflora])

    #se riesco a salvare il plot passando tutte le restrizioni
    if @new_euflora.save
      #carico nuovamente i plot
      @euflora = Euflora.find(:all,:order => "codice_eu")
      #aggiorno la tabella dei plot e chiudo la maschera di input
      @message = "Nuova specie europea aggiunta."
      render :update do |page|
        page.hide "display_input_errors"
        page.hide "new_euflora"
        page.replace_html "euflora_list", :partial => "eu_list", :object => [@euflora,@message]
      end
    else
      #mostro gli errori sull'input
      render :update do |page|
        page.show "display_input_errors"
        page.replace_html "display_input_errors", :partial => "input_errors", :object => @new_euflora
      end
    end
  end

end
