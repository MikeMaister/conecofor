class Admin::PresenzaSpecieController < ApplicationController
  include Riepilogo_specie
  before_filter :login_required,:admin_authorization_required


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
                                      (select distinct descrizione_pignatti as specie from erbacee where descrizione_pignatti is not null and temp = false and approved = true and deleted = false and id_plot = ?
                                        union
                                      select distinct descrizione_pignatti as specie from legnose where descrizione_pignatti is not null and temp = false and approved =  true and deleted = false and id_plot = ? order by specie)
                                        as ps left join
                                      (select distinct descrizione_pignatti as presenza, habitual_specie_note as habitual_note from erbacee where year(data) = ? and id_plot = ? and temp = false and approved = true and deleted = false
                                        union
                                      select distinct descrizione_pignatti as presenza, habitual_specie_note as habitual_note from legnose where year(data) = ? and id_plot = ? and temp = false and approved = true and deleted = false)
                                      as pp on ps.specie = pp.presenza",plot.at(i).id_plot,plot.at(i).id_plot,year.at(j).anno,plot.at(i).id_plot,year.at(j).anno,plot.at(i).id_plot]
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
      spe_pri_in = Cops.find_by_sql ["select distinct descrizione_pignatti as specie from cops where priest = 1 and in_out = 1 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null and id_plot = ? order by descrizione_pignatti",plot.at(i).id_plot]
      spe_pri_out = Cops.find_by_sql ["select distinct descrizione_pignatti as specie from cops where priest = 1 and in_out = 2 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null and id_plot = ? order by descrizione_pignatti",plot.at(i).id_plot]
      spe_est_in = Cops.find_by_sql ["select distinct descrizione_pignatti as specie from cops where priest = 2 and in_out = 1 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null and id_plot = ? order by descrizione_pignatti",plot.at(i).id_plot]
      spe_est_out = Cops.find_by_sql ["select distinct descrizione_pignatti as specie from cops where priest = 2 and in_out = 2 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null and id_plot = ? order by descrizione_pignatti",plot.at(i).id_plot]
      #inizializzo una nuova righa per la tabella finale
      row = TenXTen.new(plot.at(i),spe_pri_in,spe_pri_out,spe_est_in,spe_est_out)
      #scorro tutti gli anni
      for j in 0..year.size-1
        #carico i dati di presenza specie per il plot i anno j
        data_pri_in = Cops.find_by_sql ["select specie,presenza,habitual_note from (select distinct descrizione_pignatti as specie from cops where priest = 1 and in_out = 1 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null and id_plot = ? order by descrizione_pignatti)
                                          as spe left join (select distinct descrizione_pignatti as presenza,habitual_specie_note as habitual_note from cops where year(data) = ? and id_plot = ? and priest = 1 and in_out = 1 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti)
                                          as pre on spe.specie = pre.presenza order by specie",plot.at(i).id_plot,year.at(j).anno,plot.at(i).id_plot]
        data_pri_out = Cops.find_by_sql ["select specie,presenza,habitual_note from (select distinct descrizione_pignatti as specie from cops where priest = 1 and in_out = 2 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null and id_plot = ? order by descrizione_pignatti)
                                          as spe left join (select distinct descrizione_pignatti as presenza,habitual_specie_note as habitual_note from cops where year(data) = ? and id_plot = ? and priest = 1 and in_out = 2 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti)
                                          as pre on spe.specie = pre.presenza order by specie",plot.at(i).id_plot,year.at(j).anno,plot.at(i).id_plot]
        data_est_in = Cops.find_by_sql ["select specie,presenza,habitual_note from (select distinct descrizione_pignatti as specie from cops where priest = 2 and in_out = 1 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null and id_plot = ? order by descrizione_pignatti)
                                          as spe left join (select distinct descrizione_pignatti as presenza,habitual_specie_note as habitual_note from cops where year(data) = ? and id_plot = ? and priest = 2 and in_out = 1 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti)
                                          as pre on spe.specie = pre.presenza order by specie",plot.at(i).id_plot,year.at(j).anno,plot.at(i).id_plot]
        data_est_out = Cops.find_by_sql ["select specie,presenza,habitual_note from (select distinct descrizione_pignatti as specie from cops where priest = 2 and in_out = 2 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null and id_plot = ? order by descrizione_pignatti)
                                          as spe left join (select distinct descrizione_pignatti as presenza,habitual_specie_note as habitual_note from cops where year(data) = ? and id_plot = ? and priest = 2 and in_out = 2 and temp = false and approved = true and deleted = false and descrizione_pignatti is not null order by descrizione_pignatti)
                                          as pre on spe.specie = pre.presenza order by specie",plot.at(i).id_plot,year.at(j).anno,plot.at(i).id_plot]
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

    row = 2
    #scrivo tutte le speci per ogni anno
    #plot
    for i in 0..data50x50.size-1
      #puntatore di colonna
      column = 2
      #anni
      for j in 0..data50x50.at(i).presenza_list_column.size-1
        row_temp = row
        #speci
        for x in 0..data50x50.at(i).presenza_list_column.at(j).presenza_column.size-1
          sheet1[row_temp,column] = "*" if !data50x50.at(i).presenza_list_column.at(j).presenza_column.at(x).presenza.blank?
          sheet1[row_temp,column+1] = data50x50.at(i).presenza_list_column.at(j).presenza_column.at(x).habitual_note
          row_temp += 1
        end
        column += 2
      end
      row += data50x50.at(i).specie_column.size
      row += 1 if data50x50.at(i).specie_column.size.to_i == 0
    end

    #formattazione
    bold_center = Spreadsheet::Format.new :weight => :bold, :align => :middle, :horizontal_align => :center
    sheet1.row(0).default_format = bold_center
    sheet1.row(1).default_format = bold_center
    sheet1.column(0).default_format = bold_center


    #SHEDA 10x10
    #aggiungo un nuovo foglio di lavoro
    sheet2 = presence_file.create_worksheet :name => '10x10'
    #intestazioni
    sheet2[0,0] = "Plot"
    sheet2[0,3] = "Specie"
    sheet2[0,4] = "Anno"
    #plot diventa alta 4
    sheet2.merge_cells(0, 0, 1, 2)
    #specie diventa alta 2
    sheet2.merge_cells(0, 3, 1, 3)
    #anni diventa lunga x pari al numero di anni presenti
    sheet2.merge_cells(0, 4, 0, 4 + year.size.to_i*2 - 1)

    #puntatore
    p = 0
    #scrivo tutti gli anni presenti
    for i in 0..year.size-1
      sheet2[1,4+p] = year.at(i).anno
      #imposto la cella di ogni anno a 2 di lunghezza
      sheet2.merge_cells(1,4+p,1,4+p+1)
      p += 2
    end

    #puntatori
    p = 2
    #scrivo tutti i plot
    for i in 0..plot.size-1
      distanza_plot = get_distanza(i,data10x10)
      sheet2[p,0] = plot.at(i).id_plot
      sheet2.merge_cells(p,0,p+distanza_plot,0)
      #scrivo pri
      dist_pri = get_dist_pri(i,data10x10)
      sheet2[p,1] = "Pri"
      #scrivo in
      sheet2[p,2] = "In"
      #allargo pri
      sheet2.merge_cells(p,1,p + dist_pri -1,1)
      #allargo in
      dist_pri_in = retrieve_dist(data10x10.at(i).specie_pri_in.size)
      sheet2.merge_cells(p,2,p + dist_pri_in ,2) unless dist_pri_in == 0
      #scrivo out
      dist_pri_out = retrieve_dist(data10x10.at(i).specie_pri_out.size)
      sheet2[p+dist_pri_in+1,2] = "Out"
      sheet2.merge_cells(p+dist_pri_in+1,2,p+dist_pri_in+1+dist_pri_out,2)
      #scrivo est
      dist_est = get_dist_est(i,data10x10)
      sheet2[p+dist_pri,1] = "Est"
      #scrivo in
      sheet2[p+dist_pri,2] = "In"
      #allargo est
      sheet2.merge_cells(p+dist_pri,1,p+dist_pri+dist_est-1,1)
      #allargo in
      dist_est_in = retrieve_dist(data10x10.at(i).specie_est_in.size)
      sheet2.merge_cells(p+dist_pri,2,p+dist_pri+dist_est_in,2)
      #scrivo out
      dist_est_out = retrieve_dist(data10x10.at(i).specie_est_out.size)
      sheet2[p+dist_pri+dist_est_in+1,2] = "Out"
      sheet2.merge_cells(p+dist_pri+dist_est_in+1,2,p+dist_pri+dist_est_in+1+dist_est_out,2)

      p += distanza_plot + 1
    end

    #puntatore
    p = 2
    #scrivo pri in
    for i in 0..data10x10.size-1
      if data10x10.at(i).specie_pri_in.size == 0
        p+=1
      else
        for j in 0..data10x10.at(i).specie_pri_in.size-1
          sheet2[p,3] = data10x10.at(i).specie_pri_in.at(j).specie
          p+=1
        end
      end
      if data10x10.at(i).specie_pri_out.size == 0
        p+=1
      else
        for y in 0..data10x10.at(i).specie_pri_out.size-1
          sheet2[p,3] = data10x10.at(i).specie_pri_out.at(y).specie
          p+=1
        end
      end
      if data10x10.at(i).specie_est_in.size == 0
        p+=1
      else
        for z in 0..data10x10.at(i).specie_est_in.size-1
          sheet2[p,3] = data10x10.at(i).specie_est_in.at(z).specie
          p+=1
        end
      end
      if data10x10.at(i).specie_est_out.size == 0
        p+=1
      else
        for c in 0..data10x10.at(i).specie_est_out.size-1
          sheet2[p,3] = data10x10.at(i).specie_est_out.at(c).specie
          p+=1
        end
      end
    end

    #scrivo gli asterischi e le note
    row = 2
    start_row = row
    column = 4
    #scorro tutti i plot
    for i in 0..data10x10.size-1
      #scorro tutti gli anni
      for j in 0..year.size-1
        if data10x10.at(i).pres_list_col_pi.at(j).presenza_column.size == 0
          row += 1
        else
          #scorro tutti i pri in
          for z in 0..data10x10.at(i).pres_list_col_pi.at(j).presenza_column.size-1
            #li scrivo
            sheet2[row,column] = "*" if !data10x10.at(i).pres_list_col_pi.at(j).presenza_column.at(z).presenza.blank?
            sheet2[row,column+1] = data10x10.at(i).pres_list_col_pi.at(j).presenza_column.at(z).habitual_note
            row += 1
          end
        end
        if data10x10.at(i).pres_list_col_po.at(j).presenza_column.size == 0
          row += 1
        else
          #scorro tutti i pri out
          for z in 0..data10x10.at(i).pres_list_col_po.at(j).presenza_column.size-1
            #li scrivo
            sheet2[row,column] = "*" if !data10x10.at(i).pres_list_col_po.at(j).presenza_column.at(z).presenza.blank?
            sheet2[row,column+1] = data10x10.at(i).pres_list_col_po.at(j).presenza_column.at(z).habitual_note
            row += 1
          end
        end
        if data10x10.at(i).pres_list_col_ei.at(j).presenza_column.size == 0
          row += 1
        else
          #scorro tutti i est in
          for z in 0..data10x10.at(i).pres_list_col_ei.at(j).presenza_column.size-1
            #li scrivo
            sheet2[row,column] = "*" if !data10x10.at(i).pres_list_col_ei.at(j).presenza_column.at(z).presenza.blank?
            sheet2[row,column+1] = data10x10.at(i).pres_list_col_ei.at(j).presenza_column.at(z).habitual_note
            row += 1
          end
        end
        if data10x10.at(i).pres_list_col_eo.at(j).presenza_column.size == 0
          row += 1
        else
          #scorro tutti i est out
          for z in 0..data10x10.at(i).pres_list_col_eo.at(j).presenza_column.size-1
            #li scrivo
            sheet2[row,column] = "*" if !data10x10.at(i).pres_list_col_eo.at(j).presenza_column.at(z).presenza.blank?
            sheet2[row,column+1] = data10x10.at(i).pres_list_col_eo.at(j).presenza_column.at(z).habitual_note
            row += 1
          end
        end
        #dopo ogni anno mi sposto a destra di 2
        column += 2
        #dopo ogni anno la riga ritorna al punto di partenza
        #aggiorno il puntatore di distanza massima
        point_row = row
        #imposto la riga al punto di partenza
        row = start_row
      end
      #dopo ogni plot scritto
      #imposto la colonna al punto di partenza
      column = 4
      #aggiornare il punto di partenza alla distanza massima
      start_row = point_row
    end

    #formattazione
    bold_center = Spreadsheet::Format.new :weight => :bold, :align => :middle, :horizontal_align => :center
    sheet2.row(0).default_format = bold_center
    sheet2.row(1).default_format = bold_center
    sheet2.column(0).default_format = bold_center
    sheet2.column(1).default_format = bold_center
    sheet2.column(2).default_format = bold_center


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

  def get_distanza(posizione_plot,data)
    dist = 0
    dist += 1 if data.at(posizione_plot).specie_pri_in.size == 0
    dist += data.at(posizione_plot).specie_pri_in.size
    dist += 1 if data.at(posizione_plot).specie_pri_out.size == 0
    dist += data.at(posizione_plot).specie_pri_out.size
    dist += 1 if data.at(posizione_plot).specie_est_in.size == 0
    dist += data.at(posizione_plot).specie_est_in.size
    dist += 1 if data.at(posizione_plot).specie_est_out.size == 0
    dist += data.at(posizione_plot).specie_est_out.size
    return dist-1
  end

  def get_dist_pri(posizione_plot,data)
    dist = 0
    #se specie_pri_in è vuoto
    if data.at(posizione_plot).specie_pri_in.size == 0
      #occupa comunque una casella
      dist += 1
    #se non lo è
    else
      #occupa tante caselle quante sono il numero delle speci presenti
      dist += data.at(posizione_plot).specie_pri_in.size
    end
    #se specie_pri_out è vuoto
    if data.at(posizione_plot).specie_pri_out.size == 0
      #occupa comunque una casella
      dist += 1
    #se non lo è
    else
      #occupa tante caselle quante sono il numero delle speci presenti
      dist += data.at(posizione_plot).specie_pri_out.size
    end
    return dist# - 1
  end

  def get_dist_est(posizione_plot,data)
    dist = 0
    if data.at(posizione_plot).specie_est_in.size == 0
      dist += 1
    else
      dist += data.at(posizione_plot).specie_est_in.size
    end
    if data.at(posizione_plot).specie_est_out.size == 0
      dist += 1
    else
      dist += data.at(posizione_plot).specie_est_out.size
    end
    return dist # - 1
  end

  def retrieve_dist(data)
    if data == 0
      return 0
    else
      return data - 1
    end
  end



end
