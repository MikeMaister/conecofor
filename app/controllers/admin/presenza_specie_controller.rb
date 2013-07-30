class Admin::PresenzaSpecieController < ApplicationController
  include Riepilogo_specie

  def index
  end

  def result
    #carico tutti i plot
    @plot = Plot.find(:all,:select => "id_plot",:conditions => "deleted = false",:order => "id_plot")
    #carito tutti gli anni delle campagne
    @year = Campagne.find(:all,:select => "anno" ,:conditions => "deleted = false", :order => "anno")
    @view = get_data_5x5(@plot,@year)
  end

  private

  def get_data_5x5(plot,year)
    #array finale che contiene tutti i dati formattati
    tabella = Array.new
    #scorro tutti i plot
    for i in 0..plot.size-1
      #carico tutte le speci presenti nel plot
      specie = Erbacee.find_by_sql "select distinct descrizione_pignatti as specie from erbacee where descrizione_pignatti is not null and temp = false and approved = true and deleted = false
                                    union
                                    select distinct descrizione_pignatti as specie from legnose where descrizione_pignatti is not null and temp = false and approved =  true and deleted = false
                                    order by specie"
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

end
