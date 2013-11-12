class Admin::VemController < ApplicationController
  before_filter :login_required,:admin_authorization_required
  before_filter :check_input ,:only => "show"

  def index
    @anno = Campagne.find_by_sql "SELECT DISTINCT anno FROM campagne WHERE deleted = false ORDER BY anno DESC"
    @vem_file = OutputFile.find(:all,:conditions => "file_type = 'VEM'", :order => "file_name")
  end

  def show
    anno = params[:anno]

    @vem_data_1200 = Cops.find_by_sql ["select campagne_id,plot_id,descrizione_pignatti,codice_europeo,codice_strato,in_out,priest,sum((select value from copertura_specifica where copertura_specifica_id = id)) as tot_copertura, substrate_type_id,certainty_species_determination_id from cops where approved = true AND deleted = false AND campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?) group by plot_id,descrizione_pignatti,codice_strato,in_out,priest",anno]
    @vem_data_400_in = Cops.find_by_sql ["select campagne_id,plot_id,descrizione_pignatti,codice_europeo,codice_strato,in_out,priest,sum((select value from copertura_specifica where copertura_specifica_id = id)) as tot_copertura, substrate_type_id,certainty_species_determination_id from cops where in_out = 1 and subplot in(4,6,7,9) and approved = true AND deleted = false AND campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?) group by plot_id,descrizione_pignatti,codice_strato,priest",anno]
    @vem_data_400_out = Cops.find_by_sql ["select campagne_id,plot_id,descrizione_pignatti,codice_europeo,codice_strato,in_out,priest,sum((select value from copertura_specifica where copertura_specifica_id = id)) as tot_copertura, substrate_type_id,certainty_species_determination_id from cops where in_out = 2 and subplot in (3,5,7,9) and approved = true AND deleted = false AND campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?) group by plot_id,descrizione_pignatti,codice_strato,priest",anno]

    if @vem_data_1200.at(0).blank? && @vem_data_400_in.at(0).blank? && @vem_data_400_out.at(0).blank?
      flash[:notice] = "Nessun dato presente con cui generare il vem."
      redirect_to :controller => "admin/vem"
    else
      #genero il vem
      @vem_list = Array.new
      #id dei record
      session[:id_count] = 0

      #genero il vem per i vari casi
      generate_vem(@vem_data_1200,1200)
      generate_vem(@vem_data_400_in,400)
      generate_vem(@vem_data_400_out,400)

      #genero il file .xls
      generate_vem_xls(@vem_list,anno)
    end
  end

  def download_vem
    file = OutputFile.find(params[:id])
    send_file "#{RAILS_ROOT}/file privati app/VEM/#{file.file_name}"
  end

  private

  def check_input
    if params[:anno].to_i == 0
      flash[:error] = "Nessun anno selezionato."
      redirect_to :controller => "admin/vem"
    end
  end

  def generate_vem(vem_data,area)
    unless vem_data.at(0).blank?
      for i in 0..vem_data.size-1
        #incremento l'id
        session[:id_count] += 1
        #creo un oggetto vem
        vem = Vem.new(vem_data.at(i),session[:id_count],area)
        #lo aggiungo alla lista dei vem
        @vem_list << vem
      end
    end
  end

  def generate_vem_xls(data_list,anno)
    require 'rubygems'
    gem 'ruby-ole','1.2.11.4'
    require 'spreadsheet'

    #creo il nuovo documento
    vem = Spreadsheet::Workbook.new
    #aggiungo un nuovo foglio di lavoro
    sheet1 = vem.create_worksheet :name => 'Foglio di lavoro 1'
    #nella prima riga metto le intestazioni
    sheet1[0,0] = "Sequenze number of plots"
    sheet1[0,1] = "Plot number"
    sheet1[0,2] = "Sample_ID"
    sheet1[0,3] = "Survey number"
    sheet1[0,4] = "Species Code"
    sheet1[0,5] = "Layer"
    sheet1[0,6] = "Substrate"
    sheet1[0,7] = "Cover of the species in the layer"
    sheet1[0,8] = "Certainty of species determinations"
    sheet1[0,9] = "Other Observation"
    #aggiungo tutti i dati
    for i in 0..data_list.size-1
      sheet1[i+1,0] = data_list.at(i).plot_sequenze_number
      sheet1[i+1,1] = data_list.at(i).plot_number
      sheet1[i+1,2] = data_list.at(i).sample_id
      sheet1[i+1,3] = data_list.at(i).survey_number
      sheet1[i+1,4] = data_list.at(i).species_code
      sheet1[i+1,5] = data_list.at(i).layer
      sheet1[i+1,6] = data_list.at(i).substrate
      sheet1[i+1,7] = data_list.at(i).cover_species_layer
      sheet1[i+1,8] = data_list.at(i).species_determination
      sheet1[i+1,9] = data_list.at(i).other_observations
    end

    #formattazione file
    bold = Spreadsheet::Format.new :weight => :bold
    10.times do |x| sheet1.row(0).set_format(x, bold) end

    #creo la directory
    dir = "#{RAILS_ROOT}/file privati app/VEM/"
    #imposto il nome del file
    file_name = "05#{anno}.xls"
    #imposto il full_path e la relative_path
    full_path = dir + file_name
    relative_path = "/VEM/#{file_name}"
    require 'ftools'
    File.makedirs dir
    #scrivo il file
    vem.write "#{RAILS_ROOT}/file privati app/VEM/#{file_name}"
    #controllo se il file è già stato salvato
    file = OutputFile.find(:first,:conditions => ["file_name = ? AND file_type = 'VEM'",file_name])
    if file.blank?
      #traccio il file nel db
      @new_vem_file = OutputFile.new
      @new_vem_file.fill_and_save(file_name,full_path,relative_path,"VEM")
    else
      #carico il file
      @new_vem_file = OutputFile.find(:first,:conditions => ["file_name = ? AND file_type = 'VEM'",file_name])
    end
  end


end
