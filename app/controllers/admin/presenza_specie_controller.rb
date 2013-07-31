class Admin::PresenzaSpecieController < ApplicationController
  include Riepilogo_specie

  def index
  end

  def result
    #carico tutti i plot
    @plot = Plot.find(:all,:select => "id_plot",:conditions => "deleted = false",:order => "id_plot")
    #carito tutti gli anni delle campagne
    @year = Campagne.find(:all,:select => "distinct anno" ,:conditions => "deleted = false", :order => "anno")
    #carico i dati
    @view_50x50 = get_data_50x50(@plot,@year)
    @view_10x10 = get_data_10x10(@plot,@year)
    #creo il file scaricabile
    @file = create_xls(@view_50x50,@view_10x10,@year,@plot)
  end

  private

  def get_data_50x50(plot,year)
    #array finale che contiene tutti i dati formattati
    tabella = Array.new
    #scorro tutti i plot
    for i in 0..plot.size-1
      #carico tutte le speci presenti nel plot
      specie = Erbacee.find_by_sql ["select distinct descrizione_pignatti as specie from erbacee where descrizione_pignatti is not null and temp = false and approved = true and deleted = false and id_plot = ?
                                    union
                                    select distinct descrizione_pignatti as specie from legnose where descrizione_pignatti is not null and temp = false and approved =  true and deleted = false and id_plot = ?
                                    order by specie",plot.at(i).id_plot,plot.at(i).id_plot]
      #inizializzo una nuova righa per la tabella finale
      row = FiftyXFifty.new(plot.at(i),specie)
      #scorro tutti gli anni
      for j in 0..year.size-1
        #carico i dati di presenza specie per il plot i anno j
        data = Erbacee.find_by_sql ["select ps.specie ,pp.presenza,pp.habitual_note from
                                      (select distinct descrizione_pignatti as specie from erbacee where descrizione_pignatti is not null and temp = false and approved = true and deleted = false
                                        union
                                      select distinct descrizione_pignatti as specie from legnose where descrizione_pignatti is not null and temp = false and approved =  true and deleted = false order by specie)
                                        as ps left join
                                      (select distinct descrizione_pignatti as presenza, habitual_specie_note as habitual_note from erbacee where year(data) = ? and id_plot = ? and temp = false and approved = true and deleted = false
                                        union
                                      select distinct descrizione_pignatti as presenza, habitual_specie_note as habitual_note from legnose where year(data) = ? and id_plot = ? and temp = false and approved = true and deleted = false)
                                      as pp on ps.specie = pp.presenza",year.at(j).anno,plot.at(i).id_plot,year.at(j).anno,plot.at(i).id_plot]
        #inizializzo una nuova presenza
        p = Presenza.new(data,year.at(j))
        row.presenza_list_column << p
      end
      #carico la riga nella tabella
      tabella << row
    end
    return tabella
  end

  def get_data_10x10(plot,year)
    #array finale che contiene tutti i dati formattati
    tabella = Array.new
    #scorro tutti i plot
    for i in 0..plot.size-1
      #carico tutte le speci presenti nel plot
      spe_pri_in = Cops.find_by_sql "select distinct descrizione_pignatti as specie from cops where priest = 1 and in_out = 1 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti"
      spe_pri_out = Cops.find_by_sql "select distinct descrizione_pignatti as specie from cops where priest = 1 and in_out = 2 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti"
      spe_est_in = Cops.find_by_sql "select distinct descrizione_pignatti as specie from cops where priest = 2 and in_out = 1 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti"
      spe_est_out = Cops.find_by_sql "select distinct descrizione_pignatti as specie from cops where priest = 2 and in_out = 2 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti"
      #inizializzo una nuova righa per la tabella finale
      row = TenXTen.new(plot.at(i),spe_pri_in,spe_pri_out,spe_est_in,spe_est_out)
      #scorro tutti gli anni
      for j in 0..year.size-1
        #carico i dati di presenza specie per il plot i anno j
        data_pri_in = Cops.find_by_sql ["select specie,presenza,habitual_note from (select distinct descrizione_pignatti as specie from cops where priest = 1 and in_out = 1 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti)
                                          as spe left join (select distinct descrizione_pignatti as presenza,habitual_specie_note as habitual_note from cops where year(data) = ? and id_plot = ? and priest = 1 and in_out = 1 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti)
                                          as pre on spe.specie = pre.presenza order by specie",year.at(j).anno,plot.at(i).id_plot]
        data_pri_out = Cops.find_by_sql ["select specie,presenza,habitual_note from (select distinct descrizione_pignatti as specie from cops where priest = 1 and in_out = 2 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti)
                                          as spe left join (select distinct descrizione_pignatti as presenza,habitual_specie_note as habitual_note from cops where year(data) = ? and id_plot = ? and priest = 1 and in_out = 2 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti)
                                          as pre on spe.specie = pre.presenza order by specie",year.at(j).anno,plot.at(i).id_plot]
        data_est_in = Cops.find_by_sql ["select specie,presenza,habitual_note from (select distinct descrizione_pignatti as specie from cops where priest = 2 and in_out = 1 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti)
                                          as spe left join (select distinct descrizione_pignatti as presenza,habitual_specie_note as habitual_note from cops where year(data) = ? and id_plot = ? and priest = 2 and in_out = 1 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti)
                                          as pre on spe.specie = pre.presenza order by specie",year.at(j).anno,plot.at(i).id_plot]
        data_est_out = Cops.find_by_sql ["select specie,presenza,habitual_note from (select distinct descrizione_pignatti as specie from cops where priest = 2 and in_out = 2 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti)
                                          as spe left join (select distinct descrizione_pignatti as presenza,habitual_specie_note as habitual_note from cops where year(data) = ? and id_plot = ? and priest = 2 and in_out = 2 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti)
                                          as pre on spe.specie = pre.presenza order by specie",year.at(j).anno,plot.at(i).id_plot]
        #inizializzo una nuova presenza
        pi = Presenza.new(data_pri_in,year.at(j))
        po = Presenza.new(data_pri_out,year.at(j))
        ei = Presenza.new(data_est_in,year.at(j))
        eo = Presenza.new(data_est_out,year.at(j))
        #le memorizzo nelle rispettive colonne
        row.pres_list_col_pi << pi
        row.pres_list_col_po << po
        row.pres_list_col_ei << ei
        row.pres_list_col_eo << eo
      end
      #carico la riga nella tabella
      tabella << row
    end
    return tabella
  end


  def create_xls(data50x50,data10x10,year,plot)
    #creo il nuovo documento
    presence_file = Spreadsheet::Workbook.new

    #SCHEDA 50X50

    #aggiungo un nuovo foglio di lavoro
    sheet1 = presence_file.create_worksheet :name => '50x50'
    #intestazioni
    sheet1[0,0] = "Plot"
    sheet1[0,1] = "Specie"
    sheet1[0,2] = "Anno"
    #plot diventa alta 2
    sheet1.merge_cells(0, 0, 1, 0)
    #specie diventa alta 2
    sheet1.merge_cells(0, 1, 1, 1)
    #anni diventa lunga x pari al numero di anni presenti
    sheet1.merge_cells(0, 2, 0, 2 + year.size.to_i*2 - 1)

    #puntatore
    p = 0
    #scrivo tutti gli anni presenti
    for i in 0..year.size-1
      sheet1[1,2+p] = year.at(i).anno
      #imposto la cella di ogni anno a 2 di lunghezza
      sheet1.merge_cells(1,2+p,1,2+p+1)
      p += 2
    end

    #puntatore
    p = 2
    #scrivo tutti i plot
    for i in 0..plot.size-1
      sheet1[p,0] = plot.at(i).id_plot
      distanza = p
      distanza = p + data50x50.at(i).specie_column.size - 1 unless data50x50.at(i).specie_column.blank?
      sheet1.merge_cells(p,0,distanza,0)
      p += data50x50.at(i).specie_column.size
      p +=1 if data50x50.at(i).specie_column.size.to_i == 0
    end

    #puntatore
    p = 2
    #scrivo tutte le speci per ogni plot
    for i in 0..data50x50.size-1
      for j in 0..data50x50.at(i).specie_column.size-1
        sheet1[p+j,1] = data50x50.at(i).specie_column.at(j).specie
      end
      p += data50x50.at(i).specie_column.size
      p += 1 if data50x50.at(i).specie_column.size.to_i == 0
    end

    #creo la directory
    dir = "#{RAILS_ROOT}/public/Presenza Specie Plot/"
    #imposto il nome del file
    file_name = "presenza specie.xls"
    #imposto il full_path e la relative_path
    full_path = dir + file_name
    relative_path = "/Presenza Specie Plot/#{file_name}"
    require 'ftools'
    File.makedirs dir
    #scrivo il file
    presence_file.write "#{RAILS_ROOT}/public/Presenza Specie Plot/#{file_name}"
    #creo l'oggetto file
    new_stat_file = OutputFile.new
    new_stat_file.fill_and_save(file_name,full_path,relative_path,"Presenza Specie")
    return new_stat_file
  end


end
