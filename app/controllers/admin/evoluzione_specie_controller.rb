class Admin::EvoluzioneSpecieController < ApplicationController

  def index

  end

  def input_mask_all
    render :update do |page|
      page.show "input_mask"
      page.replace_html "input_mask","all"
      page.hide "result"
    end
  end

  def input_mask_psc
    @plot = Plot.find(:all,:conditions => "deleted = false",:order => "id_plot")
    @campagne = Campagne.find(:all,:conditions => "deleted = false",:order => "anno")
    render :update do |page|
      page.show "input_mask"
      page.replace_html "input_mask", :partial => "survey_mask", :object => [@plot,@campagne]
      page.hide "result"
    end
  end

  def survey_result
    case params[:survey]
      when "Erb"
        #cerco i risultati nella tabella erbacee
        specie = Erbacee.find_by_sql ["SELECT DISTINCT specie_id FROM erbacee WHERE temp = false AND approved = true AND deleted = false AND plot_id = ? AND campagne_id IN (select id from campagne where anno = ?) AND specie_id IS NOT NULL",params[:plot],params[:anno]]
        #carico i dati dell'evoluzione
        @evolution,@eu_evolution = get_evolution(specie)
      when "Leg"
        #cerco i risultati nella tabella legnose
        specie = Legnose.find_by_sql ["SELECT DISTINCT specie_id FROM legnose WHERE temp = false AND approved = true AND deleted = false AND plot_id = ? AND campagne_id IN (select id from campagne where anno = ?) AND specie_id IS NOT NULL",params[:plot],params[:anno]]
        #carico i dati dell'evoluzione
        @evolution,@eu_evolution = get_evolution(specie)
      when "Cops"
        #cerco i risultati nella tabella cops
        specie = Cops.find_by_sql ["SELECT DISTINCT specie_id FROM cops WHERE temp = false AND approved = true AND deleted = false AND plot_id = ? AND campagne_id IN (select id from campagne where anno = ?) AND specie_id IS NOT NULL",params[:plot],params[:anno]]
        #carico i dati dell'evoluzione
        @evolution,@eu_evolution = get_evolution(specie)
    end
    render :update do |page|
      page.show "result"
      page.replace_html "result", :partial => "result", :object => [@evolution,@eu_evolution]
    end
  end

  private

  def get_evolution(data)
    #lista evoluzione completa
    evolution_list = Array.new
    #lista evoluzione euflora
    eu_evolution_list = Array.new
    #per ogni specie
    for i in 0..data.size-1
      #memorizzo gli id euflora
      eu_evolution_list << Specie.find(data.at(i).specie_id).euflora_id
      #lista tracking cambiamenti
      track = Array.new
      mod = TrackSpecie.find(:all, :conditions => ["specie_id = ?",data.at(i).specie_id], :order => "data desc")
      #per ogni modifica trovata la memorizzo nell'array track
      #a meno che non sia vuoto
      unless mod.blank?
        for j in 0..mod.size-1
          track << mod.at(j)
          #memorizzo gli id euflora
          eu_evolution_list << mod.at(j).euflora_id
        end
      end
      #lista evoluzione singola specie
      evolution = Array.new
      evolution << Specie.find(data.at(i).specie_id)
      evolution << track
      #pusho tutto nel risultato
      evolution_list << evolution
    end
    #elimino i duplicati euflora
    temp = eu_evolution_list.uniq
    #elimino gli elementi nil dall'array
    eu_evolution_list = temp.compact
    #formatto i dati euflora
    eu_evolution_list1 = get_euflora_evolution(eu_evolution_list)
    return evolution_list, eu_evolution_list1
  end

  def get_euflora_evolution(euflora_id_list)
    eu_evolution_list = Array.new
    for i in 0..euflora_id_list.size-1
      track = Array.new
      mod = TrackEuflora.find(:all,:conditions => ["euflora_id = ?",euflora_id_list.at(i)],:order => "data desc")
      #per ogni modifica trovata la memorizzo nell'array track
      #a meno che non sia vuoto
      unless mod.blank?
        for j in 0..mod.size-1
          track << mod.at(j)
        end
      end
      evolution = Array.new
      evolution << Euflora.find(euflora_id_list.at(i))
      evolution << track
      eu_evolution_list << evolution
    end
    return eu_evolution_list
  end

end
