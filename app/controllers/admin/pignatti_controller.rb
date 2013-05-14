class Admin::PignattiController < ApplicationController
  def index
    @pignatti = Specie.find(:all, :conditions => "deleted = false")
  end

  def new
    @new_specie = Specie.new
    @euflora = Euflora.find(:all,:order => "descrizione")
    @pignatti = Specie.find(:all, :conditions => "deleted = false")
    #apro una finestra di input
    render :update do |page|
      page.hide "display_input_errors"
      page.show "new_specie"
      page.replace_html "pignatti_list", :partial => "specie_list", :object => @pignatti
      page.replace_html 'new_specie', :partial => 'new_specie_form', :object => [@new_specie,@euflora]
    end
  end

  def close_new_specie
    #chiudo gli errori sull'input e il nuovo input
    render :update do |page|
      page.hide "new_specie"
      page.hide "display_input_errors"
    end
  end

  def save_specie
    #compilo i campi del nuovo plot
    @new_specie = Specie.new(params[:specie])

    #se riesco a salvare il plot passando tutte le restrizioni
    if @new_specie.save
      #carico nuovamente i plot
      @pignatti = Specie.find(:all, :conditions => "deleted = false")
      #aggiorno la tabella dei plot e chiudo la maschera di input
      @message = "Nuova specie aggiunta."
      render :update do |page|
        page.hide "display_input_errors"
        page.hide "new_specie"
        page.replace_html "pignatti_list", :partial => "specie_list", :object => [@pignatti,@message]
      end
    else
      #mostro gli errori sull'input
      render :update do |page|
        page.show "display_input_errors"
        page.replace_html "display_input_errors", :partial => "input_errors", :object => @new_specie
      end
    end

  end

  def edit
    @id = params[:id]
    @i = params[:i]
    #ricarico le specie
    @pignatti = Specie.find(:all, :conditions => "deleted = false")
    @euflora = Euflora.find(:all, :order => "descrizione")
    render :update do |page|
      page.hide "new_specie"
      page.hide "display_input_errors"
      page.replace_html "pignatti_list", :partial => "edit_specie", :object => [:@id,@i,@pignatti,@euflora]
    end
  end

  def close_edit
    #ricarico i plot
    @pignatti = Specie.find(:all, :conditions => "deleted = false")
    render :update do |page|
      page.hide "display_input_errors"
      page.replace_html "pignatti_list", :partial => "specie_list", :object => @pignatti
    end
  end

  def save_edit
    @new_specie = Specie.find(params[:id])
    if @new_specie.update_specie(params[:descrizione],params[:euflora_id])
      @pignatti = Specie.find(:all, :conditions => "deleted = false")
      @message = "Modifica salvata."
      render :update do |page|
        page.hide "display_input_errors"
        page.replace_html "pignatti_list", :partial => "specie_list", :object => [@pignatti,@message]
      end
    else
      @pignatti = Specie.find(:all, :conditions => "deleted = false")
      render :update do |page|
        page.show "display_input_errors"
        page.replace_html "display_input_errors", :partial => "input_errors", :object => @new_specie
      end
    end
  end

  def delete
    to_delete = Specie.find(params[:id])
    to_delete.delete_it!
    @pignatti = Specie.find(:all, :conditions => "deleted = false")
    @message = "Specie Eliminata."
    render :update do |page|
      page.hide "new_specie"
      page.hide "display_input_errors"
      page.replace_html "pignatti_list", :partial => "specie_list", :object => [@pignatti,@message]
    end
  end

end
