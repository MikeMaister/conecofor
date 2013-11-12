class Admin::ListspeController < ApplicationController
  before_filter :login_required,:admin_authorization_required

  def index
    @listspe = Listspe.find(:all,:conditions => "deleted = false")
  end

  def new
    @new_listspe = Listspe.new
    @listspe = Listspe.find(:all,:conditions => "deleted = false")
    #apro una finestra di input
    render :update do |page|
      page.hide "display_input_errors"
      page.show "new_listspe"
      page.replace_html "listspe_list", :partial => "listspe_list", :object => @listspe
      page.replace_html 'new_listspe', :partial => 'new_listspe_form', :object => @new_listspe
    end
  end

  def close_new_listspe
    #chiudo gli errori sull'input e il nuovo input
    render :update do |page|
      page.hide "new_listspe"
      page.hide "display_input_errors"
    end
  end

  def save_listspe
    #compilo i campi della nuova specie vs
    @new_listspe = Listspe.new(params[:listspe])

    #se riesco a salvare il plot passando tutte le restrizioni
    if @new_listspe.save
      @listspe = Listspe.find(:all,:conditions => "deleted = false")
      #aggiorno la tabella dei plot e chiudo la maschera di input
      @message = "Nuova Listspe aggiunta."
      render :update do |page|
        page.hide "display_input_errors"
        page.hide "new_listspe"
        page.replace_html "listspe_list", :partial => "listspe_list", :object => [@listspe,@message]
      end
    else
      #mostro gli errori sull'input
      render :update do |page|
        page.show "display_input_errors"
        page.replace_html "display_input_errors", :partial => "input_errors", :object => @new_listspe
      end
    end
  end

  def edit
    @id = params[:id]
    @i = params[:i]
    @listspe = Listspe.find(:all,:conditions => "deleted = false")
    render :update do |page|
      page.hide "new_listspe"
      page.hide "display_input_errors"
      page.replace_html "listspe_list", :partial => "edit_listspe", :object => [:@id,@i,@listspe]
    end
  end

  def close_edit
    @listspe = Listspe.find(:all,:conditions => "deleted = false")
    render :update do |page|
      page.hide "display_input_errors"
      page.replace_html "listspe_list", :partial => "listspe_list", :object => @listspe
    end
  end

  def save_edit
    @new_listspe = Listspe.find(params[:id])
    if @new_listspe.update_listspe(params[:listspe])
      @listspe = Listspe.find(:all,:conditions => "deleted = false")
      @message = "Modifica salvata."
      render :update do |page|
        page.hide "display_input_errors"
        page.replace_html "listspe_list", :partial => "listspe_list", :object => [@listspe,@message]
      end
    else
      render :update do |page|
        page.show "display_input_errors"
        page.replace_html "display_input_errors", :partial => "input_errors", :object => @new_listspe
      end
    end
  end

  def delete
    to_delete = Listspe.find(params[:id])
    to_delete.delete_it!
    @listspe = Listspe.find(:all, :conditions => "deleted = false")
    @message = "Listspe Eliminata."
    render :update do |page|
      page.hide "new_listspe"
      page.hide "display_input_errors"
      page.replace_html "listspe_list", :partial => "listspe_list", :object => [@listspe,@message]
    end
  end

end
