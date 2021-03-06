class Admin::EufloraController < ApplicationController

  def index
    @euflora = Euflora.paginate(:conditions=>"deleted = false",:order=>"codice_eu", :page => params[:page], :per_page => 30)
  end

  def new
    @new_euflora = Euflora.new
    @euflora = Euflora.paginate(:conditions=>"deleted = false",:order=>"codice_eu", :page => params[:page], :per_page => 30)
    @spe_vs = SpecieVs.find(:all,:conditions => "deleted = false", :order => "listspe")
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
      @euflora = Euflora.paginate(:conditions=>"deleted = false",:order=>"codice_eu", :page => params[:page], :per_page => 30)
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

  def edit
    @id = params[:id]
    @i = params[:i]
    #ricarico le specie
    @euflora = Euflora.paginate(:conditions=>"deleted = false",:order=>"codice_eu", :page => params[:page], :per_page => 30)
    @spe_vs = SpecieVs.find(:all,:conditions => "deleted = false")
    render :update do |page|
      page.hide "new_euflora"
      page.hide "display_input_errors"
      page.replace_html "euflora_list", :partial => "edit_euflora", :object => [:@id,@i,@euflora,@spe_vs]
    end
  end

  def close_edit
    #ricarico i plot
    @euflora = Euflora.paginate(:conditions=>"deleted = false",:order=>"codice_eu", :page => params[:page], :per_page => 30)
    render :update do |page|
      page.hide "display_input_errors"
      page.replace_html "euflora_list", :partial => "eu_list", :object => @euflora
    end
  end

  def save_edit
    @new_euflora = Euflora.find(params[:id])
    if @new_euflora.update_eu(params[:codice_eu],params[:descrizione],params[:famiglia],params[:specie],params[:specie_vs_id])
      @euflora = Euflora.paginate(:conditions=>"deleted = false",:order=>"codice_eu", :page => params[:page], :per_page => 30)
      @message = "Modifica salvata."
      render :update do |page|
        page.hide "display_input_errors"
        page.replace_html "euflora_list", :partial => "eu_list", :object => [@euflora,@message]
      end
    else
      @euflora = Euflora.paginate(:conditions=>"deleted = false",:order=>"codice_eu", :page => params[:page], :per_page => 30)
      render :update do |page|
        page.show "display_input_errors"
        page.replace_html "display_input_errors", :partial => "input_errors", :object => @new_euflora
      end
    end
  end

  def delete
    to_delete = Euflora.find(params[:id])
    to_delete.delete_it!
    @euflora = Euflora.paginate(:conditions=>"deleted = false",:order=>"codice_eu", :page => params[:page], :per_page => 30)
    @message = "Specie europea Eliminata."
    render :update do |page|
      page.hide "new_euflora"
      page.hide "display_input_errors"
      page.replace_html "euflora_list", :partial => "eu_list", :object => [@euflora,@message]
    end
  end

end
