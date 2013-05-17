class Admin::SpecieVsController < ApplicationController

  def index
    #@specie_vs = SpecieVs.find(:all,:conditions => "deleted = false")
    @specie_vs = SpecieVs.paginate(:all,:conditions => "deleted = false", :page => params[:page], :per_page => 30)
  end

  def new
    @new_specie_vs = SpecieVs.new
    #@specie_vs = SpecieVs.find(:all,:conditions => "deleted = false")
    @specie_vs = SpecieVs.paginate(:all,:conditions => "deleted = false", :page => params[:page], :per_page => 30)
    #apro una finestra di input
    render :update do |page|
      page.hide "display_input_errors"
      page.show "new_specie_vs"
      page.replace_html "vs_spe_list", :partial => "specie_vs_list", :object => @specie_vs
      page.replace_html 'new_specie_vs', :partial => 'new_specie_vs_form', :object => @new_specie_vs
    end
  end

  def close_new_specie_vs
    #chiudo gli errori sull'input e il nuovo input
    render :update do |page|
      page.hide "new_specie_vs"
      page.hide "display_input_errors"
    end
  end

  def save_specie_vs
    #compilo i campi della nuova specie vs
    @new_specie_vs = SpecieVs.new(params[:specie_vs])

    #se riesco a salvare il plot passando tutte le restrizioni
    if @new_specie_vs.save
      #carico nuovamente le specie vs
      #@specie_vs = SpecieVs.find(:all,:conditions => "deleted = false")
      @specie_vs = SpecieVs.paginate(:all,:conditions => "deleted = false", :page => params[:page], :per_page => 30)
      #aggiorno la tabella dei plot e chiudo la maschera di input
      @message = "Nuova specie VS aggiunta."
      render :update do |page|
        page.hide "display_input_errors"
        page.hide "new_specie_vs"
        page.replace_html "vs_spe_list", :partial => "specie_vs_list", :object => [@specie_vs,@message]
      end
    else
      #mostro gli errori sull'input
      render :update do |page|
        page.show "display_input_errors"
        page.replace_html "display_input_errors", :partial => "input_errors", :object => @new_specie_vs
      end
    end
  end

  def edit
    @id = params[:id]
    @i = params[:i]
    #ricarico le specie vs
    #@specie_vs = SpecieVs.find(:all, :conditions => "deleted = false")
    @specie_vs = SpecieVs.paginate(:all,:conditions => "deleted = false", :page => params[:page], :per_page => 30)
    render :update do |page|
      page.hide "new_specie_vs"
      page.hide "display_input_errors"
      page.replace_html "vs_spe_list", :partial => "edit_specie_vs", :object => [:@id,@i,@specie_vs]
    end
  end

  def close_edit
    #ricarico i plot
    #@specie_vs = SpecieVs.find(:all, :conditions => "deleted = false")
    @specie_vs = SpecieVs.paginate(:all,:conditions => "deleted = false", :page => params[:page], :per_page => 30)
    render :update do |page|
      page.hide "display_input_errors"
      page.replace_html "vs_spe_list", :partial => "specie_vs_list", :object => @specie_vs
    end
  end

  def save_edit
    @new_specie_vs = SpecieVs.find(params[:id])
    if @new_specie_vs.update_specie_vs(params[:species],params[:listspe])
      #@specie_vs = SpecieVs.find(:all, :conditions => "deleted = false")
      @specie_vs = SpecieVs.paginate(:all,:conditions => "deleted = false", :page => params[:page], :per_page => 30)
      @message = "Modifica salvata."
      render :update do |page|
        page.hide "display_input_errors"
        page.replace_html "vs_spe_list", :partial => "specie_vs_list", :object => [@specie_vs,@message]
      end
    else
      #@specie_vs = SpecieVs.find(:all, :conditions => "deleted = false")
      @specie_vs = SpecieVs.paginate(:all,:conditions => "deleted = false", :page => params[:page], :per_page => 30)
      render :update do |page|
        page.show "display_input_errors"
        page.replace_html "display_input_errors", :partial => "input_errors", :object => @new_specie_vs
      end
    end
  end

  def delete
    to_delete = SpecieVs.find(params[:id])
    to_delete.delete_it!
    #@specie_vs = SpecieVs.find(:all, :conditions => "deleted = false")
    @specie_vs = SpecieVs.paginate(:all,:conditions => "deleted = false", :page => params[:page], :per_page => 30)
    @message = "Specie VS Eliminata."
    render :update do |page|
      page.hide "new_specie_vs"
      page.hide "display_input_errors"
      page.replace_html "vs_spe_list", :partial => "specie_vs_list", :object => [@specie_vs,@message]
    end
  end
end
