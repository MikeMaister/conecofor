class Admin::MandatoryMaskController < ApplicationController
  before_filter :login_required,:admin_authorization_required
  before_filter :mask_deletable? , :only => :delete_mask

  def index
    @mask = MandatoryMask.find_by_sql("SELECT DISTINCT mask_name FROM mandatory_mask WHERE deleted = false")
  end

  def show_model

    @mask_name = params[:mask]
    @mask_cops = MandatoryMask.find(:all, :conditions => ["survey = 'Cops' AND mask_name = ? AND deleted = false",@mask_name])
    @mask_copl = MandatoryMask.find(:all, :conditions => ["survey = 'Copl' AND mask_name = ? AND deleted = false",@mask_name])
    @mask_erb = MandatoryMask.find(:all, :conditions => ["survey = 'Erbacee' AND mask_name = ? AND deleted = false",@mask_name])
    @mask_legn = MandatoryMask.find(:all, :conditions => ["survey = 'Legnose' AND mask_name = ? AND deleted = false",@mask_name])
    @null_mask = MandatoryMask.find(:first, :conditions => ["survey = 'All null' AND mask_name = ? AND deleted = false",@mask_name])

    render :update do |page|
      page.show "mask_view"
      page.replace_html 'mask_view', :partial => 'mask_table', :object => [@mask_cops,@mask_copl,@mask_erb,@mask_legn,@mask_name]
    end
  end

  def new

    render :update do |page|
      page.show "new_mask"
      page.replace_html 'new_mask', :partial => 'new_mask_form'
    end
  end

  def create

    #setto la data e l'ora uguale per tutti i record
    data_time = Time.now
    #memorizzo il nomde della maschera
    name = params[:nome]
    not_null = "mandatory"

    if name.blank?
      flash[:error] = "Nome maschera obbligatorio."
      redirect_to :controller => "admin/mandatory_mask"
    else
      dup = MandatoryMask.find(:first,:conditions => ["mask_name = ? AND deleted = false",name])
      if dup
        flash[:error] = "Nome maschera già utilizzato."
        redirect_to :controller => "admin/mandatory_mask"
      else
        cops_parameter_list = Array.new
          cops_parameter_list << "copertura_specifica" if params[:copertura_specifica] == not_null
          cops_parameter_list << "substrate" if params[:substrate] == not_null
          cops_parameter_list << "certainty_species_determination" if params[:csd] == not_null

        copl_parameter_list = Array.new
          copl_parameter_list << "copertura_complessiva" if params[:copertura_complessiva] == not_null
          copl_parameter_list << "copertura_arboreo" if params[:copertura_arboreo] == not_null
          copl_parameter_list << "altezza_arboreo" if params[:altezza_arboreo] == not_null
          copl_parameter_list << "copertura_arbustivo" if params[:copertura_arbustivo] == not_null
          copl_parameter_list << "altezza_arbustivo" if params[:altezza_arbustivo] == not_null
          copl_parameter_list << "copertura_erbaceo" if params[:copertura_erbaceo] == not_null
          copl_parameter_list << "altezza_erbaceo" if params[:altezza_erbaceo] == not_null
          copl_parameter_list << "copertura_muscinale" if params[:copertura_muscinale] == not_null
          copl_parameter_list << "copertura_lettiera" if params[:copertura_lettiera] == not_null
          copl_parameter_list << "copertura_suolo_nudo" if params[:copertura_suolo_nudo] == not_null

        erb_parameter_list = Array.new
          erb_parameter_list << "copertura" if params[:copertura] == not_null
          erb_parameter_list << "copertura_esterna" if params[:copertura_esterna] == not_null
          erb_parameter_list << "altezza_media" if params[:altezza_media] == not_null
          erb_parameter_list << "numero_cespi" if params[:n_cespi] == not_null
          erb_parameter_list << "numero_stoloni" if params[:n_stoloni] == not_null
          erb_parameter_list << "numero_stoloni_radicanti" if params[:n_stoloni_radicanti] == not_null
          erb_parameter_list << "numero_foglie" if params[:n_foglie] == not_null
          erb_parameter_list << "numero_getti" if params[:n_getti] == not_null
          erb_parameter_list << "danni_meccanici" if params[:danni_meccanici] == not_null
          erb_parameter_list << "danni_parassitari" if params[:danni_parassitari] == not_null

        legn_parameter_list = Array.new
          legn_parameter_list << "copertura" if params[:copertura_legn] == not_null
          legn_parameter_list << "altezza" if params[:altezza_legn] == not_null
          legn_parameter_list << "eta_strutturale" if params[:eta_strutturale] == not_null
          legn_parameter_list << "danni_meccanici" if params[:danni_meccanici_legn] == not_null
          legn_parameter_list << "danni_parassitari" if params[:danni_parassitari_legn] == not_null
          legn_parameter_list << "radicanti_esterni" if params[:radicanti_esterni] == not_null

        if cops_parameter_list.blank? && copl_parameter_list.blank? && erb_parameter_list.blank? && legn_parameter_list.blank?
          flash[:notice] = "Nuova Maschera aggiunta."
          mask = MandatoryMask.new
          mask.fill_and_save("All null",name,data_time,"Null")
          redirect_to :controller => "admin/mandatory_mask"
        else

          unless cops_parameter_list.blank?
            for i in 0..cops_parameter_list.size-1
              mask = MandatoryMask.new
              mask.fill_and_save("Cops",name,data_time,cops_parameter_list.at(i))
            end
          end

          unless copl_parameter_list.blank?
            for i in 0..copl_parameter_list.size-1
              mask = MandatoryMask.new
              mask.fill_and_save("Copl",name,data_time,copl_parameter_list.at(i))
            end
          end

          unless erb_parameter_list.blank?
            for i in 0..erb_parameter_list.size-1
              mask = MandatoryMask.new
              mask.fill_and_save("Erbacee",name,data_time,erb_parameter_list.at(i))
            end
          end

          unless legn_parameter_list.blank?
            for i in 0..legn_parameter_list.size-1
              mask = MandatoryMask.new
              mask.fill_and_save("Legnose",name,data_time,legn_parameter_list.at(i))
            end
          end

          flash[:notice] = "Nuova maschera aggiunta."
          redirect_to :controller => "admin/mandatory_mask"
        end
      end
    end
  end

  def delete_mask
    mask_to_delete = MandatoryMask.find(:all, :conditions => ["mask_name = ? AND deleted = false",params[:mask_name]])

      mask_to_delete.each do |mask|
        mask.delete_it!
      end

    flash[:notice] = "Maschera #{params[:mask_name]} eliminata."
    redirect_to :controller => "admin/mandatory_mask"
  end

  private

  def mask_deletable?
    mask_association = MandatoryMaskAssociation.find(:all,:conditions => ["deleted = false AND mandatory_mask_id IN (SELECT id FROM mandatory_mask WHERE mask_name = ? AND deleted = false)",params[:mask_name]])
    unless mask_association.blank?
      flash[:error] = "La Maschera d'obbligatorietà non può essere eliminata in quanto utilizzata in una o più campagne."
      redirect_to :back
    end
  end

end
