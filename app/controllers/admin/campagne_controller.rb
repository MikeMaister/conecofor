class Admin::CampagneController < ApplicationController
  layout "application"

  def index
    @campagne = Campagne.find(:all,:conditions => ["deleted = false"])
    @campagna_attiva = Campagne.find(:first, :conditions => ["active = true"])
  end

  def show_season_note
    render :update do |page|
      page.toggle "season_note"
    end
  end

  def attiva_campagna
    #recupero la campagna attiva
    @old_campagna_attiva = Campagne.find(:first, :conditions => ["active = true"])
    #a meno che non ci sia nessuna campagna attiva
    unless @old_campagna_attiva.blank?
      #disattivo la campagna attiva
      @old_campagna_attiva.deactivate_it
    end
    #recupero il numero della campagna da attivare
    @campagna_attiva = Campagne.find(params[:n])
    #la attivo
    @campagna_attiva.active_it
    #segnalo l'attivazione
    @message_notice = "Campagna #{@campagna_attiva.descrizione} attivata."
    #ricarico tutte le campagne
    @campagne = Campagne.find(:all,:conditions => ["deleted = false"])
    render :update do |page|
      page.show "remote_message"
      page.replace_html "remote_message" ,:partial => "layouts/remote_flash_message", :object =>@message_notice
      page.replace_html "active_camp" ,:partial => "active_campagna", :object =>[@campagna_attiva]
      page.replace_html "camp_list", :partial => "campagne_list", :object =>[@campagne]
    end
  end

  def disattiva_campagna
    #recupero la campagna attiva
    @campagna_attiva = Campagne.find(:first, :conditions => ["active = true"])
    #disattivo la campagna attiva
    @campagna_attiva.deactivate_it
    #segnalo l'attivazione
    @message_notice = "Campagna #{@campagna_attiva.descrizione} disattivata"
    #ricarico tutte le campagne
    @campagne = Campagne.find(:all,:conditions => ["deleted = false"])
    #azzero la campagna per la corretta visualizzazione nel partial
    @campagna_attiva = nil
    render :update do |page|
      page.show "remote_message"
      page.replace_html "remote_message" ,:partial => "layouts/remote_flash_message", :object =>@message_notice
      page.replace_html "active_camp" ,:partial => "active_campagna", :object => @campagna_attiva
      page.replace_html "camp_list", :partial => "campagne_list", :object => @campagne
    end
  end


  def elimina_campagna
    @campagna_to_delete = Campagne.find(params[:n].to_i)
    #se la cancellazione(e invalidazione delle dipendenze) viene effettuata
    if @campagna_to_delete.delete_it
      #segnalo la cancellazione
      @message_notice = "Campagna #{@campagna_to_delete.descrizione} eliminata"
      #ricarico tutte le campagne
      @campagne = Campagne.find(:all,:conditions => ["deleted = false"])
      render :update do |page|
        page.show "remote_message"
        page.replace_html "remote_message" ,:partial => "layouts/remote_flash_message", :object =>@message_notice
        page.replace_html "camp_list", :partial => "campagne_list", :object => @campagne
      end
    end
  end

  def show_model

    model = params[:model]
    @srm = SimpleRangeModel.find(:all, :conditions => ["nome = ? AND deleted = false",model],:order => ["reference_table,attr"])

    render :update do |page|
      page.show "model_view"
      page.replace_html 'model_view', :partial => 'model_table', :object => @srm
    end
  end

  def show_mask

    mask_name = params[:mask]
    @mask_cops= MandatoryMask.find(:all, :conditions => ["survey = 'Cops' AND mask_name = ? AND deleted = false",mask_name])
    @mask_copl= MandatoryMask.find(:all, :conditions => ["survey = 'Copl' AND mask_name = ? AND deleted = false",mask_name])
    @mask_erb= MandatoryMask.find(:all, :conditions => ["survey = 'Erbacee' AND mask_name = ? AND deleted = false",mask_name])
    @mask_legn= MandatoryMask.find(:all, :conditions => ["survey = 'Legnose' AND mask_name = ? AND deleted = false",mask_name])
    @null_mask = MandatoryMask.find(:first, :conditions => ["survey = 'All null' AND mask_name = ? AND deleted = false",mask_name])


    render :update do |page|
      page.show "mask_view"
      page.replace_html 'mask_view', :partial => 'mask_table', :object => [@mask_cops,@mask_copl,@mask_erb,@mask_legn]
    end
  end

  def new_camp
    require 'calendar_date_select'
    @model = SimpleRangeModel.find_by_sql("SELECT DISTINCT nome FROM simple_range_model WHERE deleted = false")
    @mask = MandatoryMask.find_by_sql("SELECT DISTINCT mask_name FROM mandatory_mask WHERE deleted = false")
    @id_primavera = Season.find_by_nome("Primavera").id
    @id_estate = Season.find_by_nome("Estate").id
    render :update do |page|
      page.show "new_campagna"
      page.replace_html 'new_campagna', :partial => 'new_campagna_form' , :object => [@id_primavera,@id_estate,@model,@mask]
    end
  end

  def remote_save
    @new_camp = Campagne.new
    @new_camp.fill(params[:season_id],params[:inizio],params[:fine],params[:note],params[:note_stagione])

    @model = SimpleRangeModel.find(:all, :conditions => ["nome = ? AND deleted = false",params[:model]])
    @mask = MandatoryMask.find(:all, :conditions => ["mask_name = ? AND deleted = false",params[:mask]])

    if @new_camp.save && !@model.blank? && !@mask.blank?
      #associo il simple range model scelto
      camp_join_all_srm_row(@new_camp.id,@model)
      #associo la maschera d'obbligatorietà alla campagna
      camp_join_all_mm_row(@new_camp.id,@mask)
      #ricarico tutte le campagne
      @campagne = Campagne.find(:all,:conditions => ["deleted = false"])
      #avverto del nuovo inserimento
      @message_notice = "Campagna #{@new_camp.descrizione} inserita."
      render :update do |page|
        page.show "remote_message"
        page.hide "new_campagna"
        page.replace_html "remote_message" ,:partial => "layouts/remote_flash_message", :object =>@message_notice
        page.replace_html "camp_list", :partial => "campagne_list", :object => @campagne
      end
    else
      @new_model_assoc = SimpleRangeAssociation.new
      @new_mask_assoc = MandatoryMaskAssociation.new

        @new_model_assoc.errors.add(:simple_range_model_id,"non può essere vuoto.") if @model.blank?
        @new_mask_assoc.errors.add(:mandatory_mask_id,"non può essere vuoto.") if @mask.blank?

      #mostro gli errori sull'input
      render :update do |page|
        page.show "display_input_errors"
        page.replace_html "display_input_errors",:partial => "admin/campagne/input_errors", :object => [@new_camp,@new_model_assoc,@new_mask_association]
      end
    end
  end

  private

  def camp_join_all_srm_row(camp_id,srm_all_row)
    for i in 0..srm_all_row.size-1
      new_association = SimpleRangeAssociation.new
      new_association.new_camp_srm_association(camp_id,srm_all_row.at(i).id)
    end
  end

  def camp_join_all_mm_row(camp_id,mm_all_row)
    for i in 0..mm_all_row.size-1
      new_association = MandatoryMaskAssociation.new
      new_association.new_camp_mm_association(camp_id,mm_all_row.at(i).id)
    end
  end

end
