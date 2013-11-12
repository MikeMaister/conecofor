class Admin::PlvController < ApplicationController
  before_filter :login_required,:admin_authorization_required
  before_filter :check_input ,:only => "show"

  def index
    @anno = Campagne.find_by_sql "SELECT DISTINCT anno FROM campagne WHERE deleted = false ORDER BY anno DESC"
    @plv_file = OutputFile.find(:all,:conditions => "file_type = 'PLV'", :order => "file_name")
  end

  def show
    anno = params[:anno]

    #1)carico il plv(PRIMAVERA,IN,1200)
    @plv_pri_in_1200 = Copl.find_by_sql ["SELECT p.numero_plot as plot_num,c.data as data,p.latitudine as lat,p.longitudine as lon,p.altitudine as alt,SUM(c.copertura_arboreo) as t_cop_arbo,SUM(c.altezza_arbustivo) as t_alt_arbu,SUM(c.copertura_arbustivo) as t_cop_arbu,SUM(c.altezza_erbaceo) as t_alt_erb,SUM(c.copertura_erbaceo) as t_cop_erb,SUM(c.copertura_muscinale) as t_cop_musc,SUM(c.copertura_suolo_nudo) as t_cop_suol,SUM(c.copertura_lettiera) as t_cop_let FROM plot AS p,copl AS c WHERE c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 1 AND c.priest = 1 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]
    #2)carico il plv(PRIMAVERA,OUT,1200)
    @plv_pri_out_1200 = Copl.find_by_sql ["SELECT p.numero_plot as plot_num,c.data as data,p.latitudine as lat,p.longitudine as lon,p.altitudine as alt,SUM(c.copertura_arboreo) as t_cop_arbo,SUM(c.altezza_arbustivo) as t_alt_arbu,SUM(c.copertura_arbustivo) as t_cop_arbu,SUM(c.altezza_erbaceo) as t_alt_erb,SUM(c.copertura_erbaceo) as t_cop_erb,SUM(c.copertura_muscinale) as t_cop_musc,SUM(c.copertura_suolo_nudo) as t_cop_suol,SUM(c.copertura_lettiera) as t_cop_let FROM plot AS p,copl AS c WHERE c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 2 AND c.priest = 1 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]
    #3) carico il plv(ESTATE,IN,1200)
    @plv_est_in_1200 = Copl.find_by_sql ["SELECT p.numero_plot as plot_num,c.data as data,p.latitudine as lat,p.longitudine as lon,p.altitudine as alt,SUM(c.copertura_arboreo) as t_cop_arbo,SUM(c.altezza_arbustivo) as t_alt_arbu,SUM(c.copertura_arbustivo) as t_cop_arbu,SUM(c.altezza_erbaceo) as t_alt_erb,SUM(c.copertura_erbaceo) as t_cop_erb,SUM(c.copertura_muscinale) as t_cop_musc,SUM(c.copertura_suolo_nudo) as t_cop_suol,SUM(c.copertura_lettiera) as t_cop_let FROM plot AS p,copl AS c WHERE c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 1 AND c.priest = 2 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]
    #4) carico il plv(ESTATE,OUT,1200)
    @plv_est_out_1200 = Copl.find_by_sql ["SELECT p.numero_plot as plot_num,c.data as data,p.latitudine as lat,p.longitudine as lon,p.altitudine as alt,SUM(c.copertura_arboreo) as t_cop_arbo,SUM(c.altezza_arbustivo) as t_alt_arbu,SUM(c.copertura_arbustivo) as t_cop_arbu,SUM(c.altezza_erbaceo) as t_alt_erb,SUM(c.copertura_erbaceo) as t_cop_erb,SUM(c.copertura_muscinale) as t_cop_musc,SUM(c.copertura_suolo_nudo) as t_cop_suol,SUM(c.copertura_lettiera) as t_cop_let FROM plot AS p,copl AS c WHERE c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 2 AND c.priest = 2 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]
    #5) carico il plv(PRIMAVERA,IN,400)
    @plv_pri_in_400 = Copl.find_by_sql ["SELECT p.numero_plot as plot_num,c.data as data,p.latitudine as lat,p.longitudine as lon,p.altitudine as alt,SUM(c.copertura_arboreo) as t_cop_arbo,SUM(c.altezza_arbustivo) as t_alt_arbu,SUM(c.copertura_arbustivo) as t_cop_arbu,SUM(c.altezza_erbaceo) as t_alt_erb,SUM(c.copertura_erbaceo) as t_cop_erb,SUM(c.copertura_muscinale) as t_cop_musc,SUM(c.copertura_suolo_nudo) as t_cop_suol,SUM(c.copertura_lettiera) as t_cop_let FROM plot AS p,copl AS c WHERE c.subplot IN(4,6,7,9) and  c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 1 AND c.priest = 1 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]
    #6) carico il plv(PRIMAVERA,OUT,400)
    @plv_pri_out_400 = Copl.find_by_sql ["SELECT p.numero_plot as plot_num,c.data as data,p.latitudine as lat,p.longitudine as lon,p.altitudine as alt,SUM(c.copertura_arboreo) as t_cop_arbo,SUM(c.altezza_arbustivo) as t_alt_arbu,SUM(c.copertura_arbustivo) as t_cop_arbu,SUM(c.altezza_erbaceo) as t_alt_erb,SUM(c.copertura_erbaceo) as t_cop_erb,SUM(c.copertura_muscinale) as t_cop_musc,SUM(c.copertura_suolo_nudo) as t_cop_suol,SUM(c.copertura_lettiera) as t_cop_let FROM plot AS p,copl AS c WHERE c.subplot IN(3,5,7,9) and c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 2 AND c.priest = 1 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]
    #7) carito il plv(ESTATE,IN,400)
    @plv_est_in_400 = Copl.find_by_sql ["SELECT p.numero_plot as plot_num,c.data as data,p.latitudine as lat,p.longitudine as lon,p.altitudine as alt,SUM(c.copertura_arboreo) as t_cop_arbo,SUM(c.altezza_arbustivo) as t_alt_arbu,SUM(c.copertura_arbustivo) as t_cop_arbu,SUM(c.altezza_erbaceo) as t_alt_erb,SUM(c.copertura_erbaceo) as t_cop_erb,SUM(c.copertura_muscinale) as t_cop_musc,SUM(c.copertura_suolo_nudo) as t_cop_suol,SUM(c.copertura_lettiera) as t_cop_let FROM plot AS p,copl AS c WHERE c.subplot IN(4,6,7,9) and c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 1 AND c.priest = 2 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]
    #8) carico il plv(ESTATE,OUT,400)
    @plv_est_out_400 = Copl.find_by_sql ["SELECT p.numero_plot as plot_num,c.data as data,p.latitudine as lat,p.longitudine as lon,p.altitudine as alt,SUM(c.copertura_arboreo) as t_cop_arbo,SUM(c.altezza_arbustivo) as t_alt_arbu,SUM(c.copertura_arbustivo) as t_cop_arbu,SUM(c.altezza_erbaceo) as t_alt_erb,SUM(c.copertura_erbaceo) as t_cop_erb,SUM(c.copertura_muscinale) as t_cop_musc,SUM(c.copertura_suolo_nudo) as t_cop_suol,SUM(c.copertura_lettiera) as t_cop_let FROM plot AS p,copl AS c WHERE c.subplot IN(3,5,7,9) and c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 2 AND c.priest = 2 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]

    if @plv_pri_in_1200.at(0).plot_num.blank? && @plv_pri_out_1200.at(0).plot_num.blank? && @plv_est_in_1200.at(0).plot_num.blank? && @plv_est_out_1200.at(0).plot_num.blank? && @plv_pri_in_400.at(0).plot_num.blank? && @plv_pri_out_400.at(0).plot_num.blank? && @plv_est_in_400.at(0).plot_num.blank? && @plv_est_out_400.at(0).plot_num.blank?
      flash[:notice] = "Nessun dato presente con cui generare il plv."
      redirect_to :controller => "admin/plv"
    else
      #creo una lista per i plv
      @plv_list = Array.new
      #id dei record
      session[:id_count] = 0

      #si possono ridurre le query verso il db a 3
      #1 per i 1200
      #1 per i 400 in (perchè hanno su diverse)
      #1 per i 400 out (perchè hanno su diverse)

      #1)
      #raccolgo gli altri dati mancanti
      @ppi1200_note = Copl.find_by_sql ["SELECT c.note as note FROM plot AS p,copl AS c WHERE c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 1 AND c.priest = 1 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]
      #genero il plv parziale
      generate_plv(@plv_pri_in_1200,@ppi1200_note,12,1200,"in","Primavera",@plv_list)

      #2)
      #raccolgo gli altri dati mancanti
      @ppo1200_note = Copl.find_by_sql ["SELECT c.note as note FROM plot AS p,copl AS c WHERE c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 2 AND c.priest = 1 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]
      #genero il plv parziale
      generate_plv(@plv_pri_out_1200,@ppo1200_note,12,1200,"out","Primavera",@plv_list)

      #3)
      #raccolgo gli altri dati mancanti
      @pei1200_note = Copl.find_by_sql ["SELECT c.note as note FROM plot AS p,copl AS c WHERE c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 1 AND c.priest = 2 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]
      #genero il plv parziale
      generate_plv(@plv_est_in_1200,@pei1200_note,12,1200,"in","Estate",@plv_list)

      #4)
      #raccolgo gli altri dati mancanti
      @peo1200_note = Copl.find_by_sql ["SELECT c.note as note FROM plot AS p,copl AS c WHERE c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 2 AND c.priest = 2 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]
      #genero il plv parziale
      generate_plv(@plv_est_out_1200,@peo1200_note,12,1200,"out","Estate",@plv_list)

      #5)
      #raccolgo gli altri dati mancanti
      @ppi400_note = Copl.find_by_sql ["SELECT c.note as note FROM plot AS p,copl AS c WHERE c.subplot IN(4,6,7,9) and c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 1 AND c.priest = 1 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]
      #genero il plv parziale
      generate_plv(@plv_pri_in_400,@ppi400_note,4,400,"in","Primavera",@plv_list)

      #6)
      #raccolgo gli altri dati mancanti
      @ppo400_note = Copl.find_by_sql ["SELECT c.note as note FROM plot AS p,copl AS c WHERE c.subplot IN(3,5,7,9) and c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 2 AND c.priest = 1 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]
      #genero il plv parziale
      generate_plv(@plv_pri_out_400,@ppo400_note,4,400,"out","Primavera",@plv_list)

      #7)
      #raccolgo gli altri dati mancanti
      @pei400_note = Copl.find_by_sql ["SELECT c.note as note FROM plot AS p,copl AS c WHERE c.subplot IN(4,6,7,9) and c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 1 AND c.priest = 2 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]
      #genero il plv parziale
      generate_plv(@plv_est_in_400,@pei400_note,4,400,"in","Estate",@plv_list)

      #8)
      #raccolgo gli altri dati mancanti
      @peo400_note = Copl.find_by_sql ["SELECT c.note as note FROM plot AS p,copl AS c WHERE c.subplot IN(3,5,7,9) and c.approved = true AND c.temp = false AND c.deleted = false AND p.deleted = false AND p.id = c.plot_id AND c.in_out = 2 AND c.priest = 2 AND c.campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?)",anno]
      #genero il plv parziale
      generate_plv(@plv_est_out_400,@peo400_note,4,400,"out","Estate",@plv_list)

      #genero il file plv.xls
      generate_plv_xls(@plv_list,anno)

    end
  end

  private

  def check_input
    if params[:anno].to_i == 0
      flash[:error] = "Nessun anno selezionato."
      redirect_to :controller => "admin/plv"
    end
  end

  def generate_plv(plv_data,plv_note,plv_su_num,su_area,in_out,season,plv_list)
    unless plv_data.at(0).plot_num.blank?
      #per ogni record trovato(sarebbe per ogni plot)
      for i in 0..plv_data.size-1
        #incremento di 1 l'id_count per ogni plv che aggiungo
        session[:id_count] += 1
        #creo un plv
        plv = Plv.new(plv_data.at(i),plv_note,plv_su_num,session[:id_count],su_area,in_out,season)
        #aggiungo il plv alla lista dei plv
        plv_list << plv
      end
    end
  end

  def generate_plv_xls(data_list,anno)
    require 'rubygems'
    gem 'ruby-ole','1.2.11.4'
    require 'spreadsheet'

    #creo il nuovo documento
    plv = Spreadsheet::Workbook.new
    #aggiungo un nuovo foglio di lavoro
    sheet1 = plv.create_worksheet :name => 'Foglio di lavoro 1'
    #nella prima riga metto le intestazioni
    sheet1[0,0] = "Sequenze number of plots"
    sheet1[0,1] = "Country Code"
    sheet1[0,2] = "Plot number"
    sheet1[0,3] = "Sample_ID"
    sheet1[0,4] = "Team ID"
    sheet1[0,5] = "Number of the team members"
    sheet1[0,6] = "Survey type"
    sheet1[0,7] = "Survey number"
    sheet1[0,8] = "Date of sampling"
    sheet1[0,9] = "Latitude"
    sheet1[0,10] = "Longitude"
    sheet1[0,11] = "Altitude"
    sheet1[0,12] = "Fence"
    sheet1[0,13] = "Total sampled area"
    sheet1[0,14] = "Tree layer cover"
    sheet1[0,15] = "Shrub layer height"
    sheet1[0,16] = "Shrub layer cover"
    sheet1[0,17] = "Herb layer height"
    sheet1[0,18] = "Herb layer cover"
    sheet1[0,19] = "Mosses cover"
    sheet1[0,20] = "Bare soil cover"
    sheet1[0,21] = "Litter cover"
    sheet1[0,22] = "Other observations"
    #aggiungo tutti i dati
    for i in 0..data_list.size-1
      sheet1[i+1,0] = data_list.at(i).plot_seq_number
      sheet1[i+1,1] = data_list.at(i).country_code
      sheet1[i+1,2] = data_list.at(i).plot_number
      sheet1[i+1,3] = data_list.at(i).sample_id
      sheet1[i+1,4] = data_list.at(i).team_id
      sheet1[i+1,5] = data_list.at(i).team_members
      sheet1[i+1,6] = data_list.at(i).survey_type
      sheet1[i+1,7] = data_list.at(i).survey_number
      sheet1[i+1,8] = data_list.at(i).date
      sheet1[i+1,9] = data_list.at(i).latitude
      sheet1[i+1,10] = data_list.at(i).longitude
      sheet1[i+1,11] = data_list.at(i).altitude
      sheet1[i+1,12] = data_list.at(i).fence
      sheet1[i+1,13] = data_list.at(i).total_area
      sheet1[i+1,14] = data_list.at(i).tree_layer_cover
      sheet1[i+1,15] = data_list.at(i).shrub_layer_height
      sheet1[i+1,16] = data_list.at(i).shrub_layer_cover
      sheet1[i+1,17] = data_list.at(i).herb_layer_height
      sheet1[i+1,18] = data_list.at(i).herb_layer_cover
      sheet1[i+1,19] = data_list.at(i).mosses_cover
      sheet1[i+1,20] = data_list.at(i).bare_soil_cover
      sheet1[i+1,21] = data_list.at(i).litter_cover
      sheet1[i+1,22] = data_list.at(i).other_observations
    end

    #formattazione file
    bold = Spreadsheet::Format.new :weight => :bold
    23.times do |x| sheet1.row(0).set_format(x, bold) end

    #creo la directory
    dir = "#{RAILS_ROOT}/public/PLV/"
    #imposto il nome del file
    file_name = "05#{anno}.xls"
    #imposto il full_path e la relative_path
    full_path = dir + file_name
    relative_path = "/PLV/#{file_name}"
    require 'ftools'
    File.makedirs dir
    #scrivo il file
    plv.write "#{RAILS_ROOT}/public/PLV/#{file_name}"
    #controllo se il file è già stato salvato
    file = OutputFile.find(:first,:conditions => ["file_name = ? AND file_type = 'PLV'",file_name])
    if file.blank?
      #traccio il file nel db
      @new_plv_file = OutputFile.new
      @new_plv_file.fill_and_save(file_name,full_path,relative_path,"PLV")
    else
      #carico il file
      @new_plv_file = OutputFile.find(:first,:conditions => ["file_name = ? AND file_type = 'PLV'",file_name])
    end
  end


end
