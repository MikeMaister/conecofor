class Admin::CheckSpeciesController < ApplicationController
  before_filter :login_required,:admin_authorization_required

  def index
  end

  def check

    str = /\D/

    if params[:upload].blank? || params[:column_species].blank?
      #avviso
      flash[:error] = "Riempi tutti i campi prima di proseguire."
      redirect_to :controller => 'admin/check_species'
    elsif !valid_file?(params[:upload])
      #avviso
      flash[:error] = "Tipo di file non valido."
      redirect_to :controller => 'admin/check_species'
    elsif params[:column_species] =~ str
      #avviso
      flash[:error] = "Il campo colonna specie n° ammette solo valori numerici."
      redirect_to :controller => 'admin/check_species'
    else
      #salvo il file sul server
      upload_file(params[:upload])
      results(name = (params[:upload])['datafile'].original_filename,params[:column_species].to_i-1)
    end
  end

  private

  def results(file_name,col_num)
    require 'rubygems'
    gem 'ruby-ole','1.2.11.4'
    require 'spreadsheet'

    #imposto la codifica dei caratteri
    Spreadsheet.client_encoding = 'UTF-8'
    #apro il file
    doc = Spreadsheet.open "file privati app/controllo specie/#{file_name}"
    #imposto il foglio di lavoro
    sheet = doc.worksheet 0

    #serve per vedere se la colonna è interamente vuota
    column_full = false

    #conterrà tutti gli errori trovati sul file
    @error_list = Array.new
    #numero della colonna (va incrementato in quanto quella corrispondente sul documento è -1 rispetto il valore immesso)
    @column = col_num + 1

    #scorro il file
    sheet.each_with_index do |row,i|
      #a meno che la riga non sia vuota (sulla colonna indicata)
      unless row[col_num].blank?
        #c'è almeno un valore nella colonna indicata
        column_full = true
        #fa saltare la prima riga
        if i != 0
          #cerco la specie in tabella confrontandola con quella della riga attuale
          specie = Specie.find(:first, :conditions => ["descrizione = ? AND deleted = false", row[col_num]])
          #se la specie non è stata trovata nel database
          if specie.blank?
            #creo un nuovo errore sulla riga
            row_error = Array.new
            #memorizzo la riga d'interesse
            row_error << i+1
            #memorizzo la specie che ha generato l'errore
            row_error << row[col_num]
            #assegno l'errore all'array di errori
            @error_list << row_error
          end
        end
      end
    end
    #se la colonna è risultata essere interamente vuota
    if column_full == false
      #avviso
      flash[:error] = "La colonna indicata del file risulta essere vuota."
      redirect_to :controller => 'admin/check_species'
    else
      return @error_list
    end
  end

  #controlla il tipo di file
  def valid_file?(file)
    #prendo il nome
    name = (file)['datafile'].original_filename
    #imposto un file di tipo concordato .xls
    xls = /.*[.][x][l][s]/
    #se è un file di tipo .xls ritorno true
    true if name =~ xls
  end

  def upload_file(file)
    name = (file)['datafile'].original_filename
    #CAMBIARE LA DIRECTORY CON QUELLA DEL SERVER(non nella cartella public)
    directory = "#{RAILS_ROOT}/file privati app/controllo specie"
    #creo la cartella
    require 'ftools'
    File.makedirs directory
    #create the file path
    path = File.join(directory, name)
    #write the file
    File.open(path, "wb") { |f| f.write(file['datafile'].read) }
  end

end
