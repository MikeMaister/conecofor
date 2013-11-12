class Admin::VsController < ApplicationController
  before_filter :login_required,:admin_authorization_required
  before_filter :check_input, :only => :show

  def index
    @anno = Campagne.find_by_sql "SELECT DISTINCT anno FROM campagne WHERE deleted = false ORDER BY anno DESC"
    @vs_file = OutputFile.find(:all,:conditions => "file_type = 'VS'", :order => "file_name")
  end

  def show
    anno = params[:anno]

    #carico tutti i dati corrispondenti all'anno selezionato secondo i criteri stabiliti
    data = Cops.find(:all, :conditions => ["temp = false AND approved = true AND deleted = false AND in_out = 1 AND priest = 2 AND campagne_id IN (SELECT id FROM campagne WHERE deleted = false AND anno = ?) AND plot_id IN (SELECT id FROM plot WHERE im IS NOT NULL)",anno])
    if data.blank?
      flash[:notice] = "Nessun dato presente con cui generare il VS."
      redirect_to :action => :index
    else
      #qua memorizzo tutti i record vs
      @vs_list = Array.new

      #genero il vs
      for i in 0..data.size-1
        temp_vs = Vs.new(data.at(i))
        @vs_list << temp_vs
      end

      #genero il file vs.xls
      generate_vs_xls(@vs_list,anno)
    end
  end

  private

  def check_input
    if params[:anno].to_i == 0
      flash[:error] = "Nessun anno selezionato."
      redirect_to :controller => "admin/vs"
    end
  end


  def generate_vs_xls(data_list,anno)
    require 'rubygems'
    gem 'ruby-ole','1.2.11.4'
    require 'spreadsheet'

    #creo il nuovo documento
    vs = Spreadsheet::Workbook.new
    #aggiungo un nuovo foglio di lavoro
    sheet1 = vs.create_worksheet :name => 'Foglio di lavoro 1'
    #nella prima riga metto le intestazioni
    sheet1[0,0] = "Subprog"
    sheet1[0,1] = "Area"
    sheet1[0,2] = "Inst"
    sheet1[0,3] = "Scode"
    sheet1[0,4] = "Medium"
    sheet1[0,5] = "Listmed"
    sheet1[0,6] = "Size"
    sheet1[0,7] = "YYYYMM"
    sheet1[0,8] = "Spool"
    sheet1[0,9] = "Pflag"
    sheet1[0,10] = "Species"
    sheet1[0,11] = "Listspe"
    sheet1[0,12] = "Class"
    sheet1[0,13] = "Param"
    sheet1[0,14] = "Parlist"
    sheet1[0,15] = "Value"
    sheet1[0,16] = "Unit"
    sheet1[0,17] = "Flagqua"
    sheet1[0,18] = "Flagsta"
    #aggiungo tutti i dati
    for i in 0..data_list.size-1
      sheet1[i+1,0] = data_list.at(i).subprog
      sheet1[i+1,1] = data_list.at(i).area
      sheet1[i+1,2] = data_list.at(i).inst
      sheet1[i+1,3] = data_list.at(i).scode
      sheet1[i+1,4] = data_list.at(i).medium
      sheet1[i+1,5] = data_list.at(i).listmed
      sheet1[i+1,6] = data_list.at(i).size
      sheet1[i+1,7] = data_list.at(i).yyyymm
      sheet1[i+1,8] = data_list.at(i).spool
      sheet1[i+1,9] = data_list.at(i).pflag
      sheet1[i+1,10] = data_list.at(i).species
      sheet1[i+1,11] = data_list.at(i).listspe
      sheet1[i+1,12] = data_list.at(i).class
      sheet1[i+1,13] = data_list.at(i).param
      sheet1[i+1,14] = data_list.at(i).parlist
      sheet1[i+1,15] = data_list.at(i).value
      sheet1[i+1,16] = data_list.at(i).unit
      sheet1[i+1,17] = data_list.at(i).flagqua
      sheet1[i+1,18] = data_list.at(i).flagsta
    end

    #formattazione file
    bold = Spreadsheet::Format.new :weight => :bold
    19.times do |x| sheet1.row(0).set_format(x, bold) end

    #creo la directory
    dir = "#{RAILS_ROOT}/public/VS/"
    #imposto il nome del file
    file_name = "IM It#{anno}vs.xls"
    #imposto il full_path e la relative_path
    full_path = dir + file_name
    relative_path = "/VS/#{file_name}"
    require 'ftools'
    File.makedirs dir
    #scrivo il file
    vs.write "#{RAILS_ROOT}/public/VS/#{file_name}"
    #controllo se il file è già stato salvato
    file = OutputFile.find(:first,:conditions => ["file_name = ? AND file_type = 'VS'",file_name])
    if file.blank?
      #traccio il file nel db
      @new_vs_file = OutputFile.new
      @new_vs_file.fill_and_save(file_name,full_path,relative_path,"VS")
    else
      #carico il file
      @new_vs_file = OutputFile.find(:first,:conditions => ["file_name = ? AND file_type = 'VS'",file_name])
    end
  end

end
