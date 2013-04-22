class Admin::SimpleRangeModelController < ApplicationController

  before_filter [:srm_form_blank?,:srm_form_numeric?,:srm_duplicate_name?], :only => "create"
  before_filter :srm_deletable?, :only => :delete_srm

  def index
    @model = SimpleRangeModel.find_by_sql("SELECT DISTINCT nome FROM simple_range_model WHERE deleted = false")
    @srm = SimpleRangeModel.find(:all, :conditions => ["deleted = false"])
  end

  def show_model

    model = params[:model]
    @srm = SimpleRangeModel.find(:all, :conditions => ["nome = ? AND deleted = false",model],:order => ["reference_table,attr"])

    render :update do |page|
      page.show "model_view"
      page.replace_html 'model_view', :partial => 'model_table', :object => @srm
    end
  end


  def new
    @standard_srm = SimpleRangeModel.find(:all, :conditions => ["nome = 'Standard' AND deleted = false"],:order => ["reference_table,attr"])

    render :update do |page|
      page.show "new_model"
      page.replace_html 'new_model', :partial => 'new_model_form', :object => @standard_srm
    end
  end

  def create
      #la sua dimensione serve per ciclare tutti i params (la query deve essere uguale a quella della schermata di inserimento)
      @standard_srm = SimpleRangeModel.find(:all, :conditions => ["nome = 'Standard' AND deleted = false"],:order => ["reference_table,attr"])

      #setto la data e l'ora uguale per tutti i record
      data_time = Time.now

      for i in 0..@standard_srm.size-1
        src = SimpleRangeModel.new
        src.fill_and_save(params[:nome],@standard_srm.at(i).reference_table,@standard_srm.at(i).attr,params["min#{i}"],params["max#{i}"],data_time)
      end
      flash[:notice] = "Nuovo modello aggiunto."
      redirect_to :controller => "admin/simple_range_model"
  end

  def delete_srm
    @record_to_delete = SimpleRangeModel.find(:all,:conditions => ["nome = ?", params[:nome]])

    for i in 0..@record_to_delete.size-1
      @record_to_delete.at(i).delete!
    end

    flash[:notice] = "Il modello denominato #{params[:nome]} è stato eliminato."
    redirect_to :controller => "admin/simple_range_model"

  end

  private

  def srm_deletable?
    srm_association = SimpleRangeAssociation.find(:all,:conditions => ["deleted = false AND simple_range_model_id IN (SELECT id FROM simple_range_model WHERE nome = ? AND deleted = false)",params[:nome]])
    unless srm_association.blank?
      flash[:error] = "Il modello src non può essere eliminato in quanto utilizzato in una o più campagne."
      redirect_to :back
    end
  end

  def srm_form_blank?
    #la sua dimensione serve per ciclare tutti i params (la query deve essere uguale a quella della schermata di inserimento)
    @standard_srm = SimpleRangeModel.find(:all, :conditions => ["nome = 'Standard' AND deleted = false"],:order => ["reference_table,attr"])

    blank = false

    for i in 0..@standard_srm.size-1
      if params["min#{i}"].blank? || params["max#{i}"].blank?
        blank = true
      end
    end

    if params[:nome].blank?
      blank = true
    end

    if blank == true
      flash[:error] = "Modello annullato: compila tutti i campi."
      redirect_to :controller => "admin/simple_range_model"
    end
  end

  def srm_form_numeric?
    #la sua dimensione serve per ciclare tutti i params (la query deve essere uguale a quella della schermata di inserimento)
    @standard_srm = SimpleRangeModel.find(:all, :conditions => ["nome = 'Standard' AND deleted = false"],:order => ["reference_table,attr"])

    str =/[^0-9.]/
    string = false

    for i in 0..@standard_srm.size-1
      if params["min#{i}"] =~ str || params["max#{i}"] =~ str
        string = true
      end
    end

    if string == true
      flash[:error] = "Modello annullato: I range accettano solamente parametri numerici."
      redirect_to :controller => "admin/simple_range_model"
    end
  end

  def srm_duplicate_name?
    dup = SimpleRangeModel.find(:first,:conditions => ["nome = ? AND deleted = false", params[:nome]])
    if dup
      flash[:error] = "Il nome selezionato per il modello è già utilizzato."
      redirect_to :controller => "admin/simple_range_model"
    end
  end

end
