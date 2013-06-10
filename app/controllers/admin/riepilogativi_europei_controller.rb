class Admin::RiepilogativiEuropeiController < ApplicationController

  def index
    @anno = Campagne.find_by_sql "SELECT DISTINCT(anno) FROM campagne WHERE deleted = false ORDER BY anno"
  end

  def result
    @anno = params[:anno]

    plot = Plot.find_by_sql ["select numero_plot from plot where deleted = false and id in (select plot_id from erbacee where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) or id  in (select plot_id from legnose where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) order by id_plot",@anno,@anno]

    #DA TENERE
    unita = Plot.find_by_sql ["select numero_plot,plot.id_plot,n_su
    from plot left join (select id_plot,count(subplot) as n_su from
    (
      select id_plot,subplot from erbacee where specie_id is not null
      and temp = false and approved = true and deleted = false and campagne_id IN
        (select id from campagne where anno = #{@anno} and deleted = false)
      group by id_plot,subplot
    union
      select id_plot ,subplot  from legnose where specie_id is not null
      and temp = false and approved = true and deleted = false and campagne_id IN
        (select id from campagne where anno = #{@anno} and deleted = false)
      group by id_plot,subplot
    )
      as temp group by id_plot order by id_plot) as temp1
    on plot.id_plot = temp1.id_plot
    where deleted = false and
	    id in (select plot_id from erbacee where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = #{@anno} and deleted = false))
	    or id  in (select plot_id from legnose where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = #{@anno} and deleted = false))
    order by id_plot"]

    #DA TENERE
    niferb = Erbacee.find_by_sql ["select numero_plot,plot.id_plot,niferb
    from plot left join (select id_plot,(coalesce(sum(numero_cespi),0) + coalesce(sum(numero_stoloni),0) + coalesce(sum(numero_getti),0)) as niferb from erbacee where specie_id is not null and deleted = false and temp = false and approved = true and campagne_id in (select id from campagne where deleted = false and anno = ?) group by id_plot order by id_plot) as temp
      on plot.id_plot = temp.id_plot
    where deleted = false and id in (select plot_id from erbacee where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) or id  in (select plot_id from legnose where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) order by id_plot",@anno,@anno,@anno]

    #DA TENERE
    nifleg = Legnose.find_by_sql ["select numero_plot,plot.id_plot,nifleg
    from plot left join (select id_plot, count(specie_id) as nifleg from legnose where deleted = false and temp = false and approved = true and campagne_id in (select id from campagne where deleted = false and anno = ?) group by id_plot order by id_plot) as temp
      on plot.id_plot = temp.id_plot
    where deleted = false and id in (select plot_id from erbacee where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) or id  in (select plot_id from legnose where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) order by id_plot",@anno,@anno,@anno]

    #DA TENERE
    coperb = Erbacee.find_by_sql ["select numero_plot,plot.id_plot,coperb
    from plot left join (select id_plot, sum(copertura) as coperb from erbacee,specie,euflora where specie_id is not null and specie_id = specie.id and euflora_id = euflora.id and (codice_eu regexp '^0' or codice_eu regexp '^1' or codice_eu regexp '^2') and erbacee.deleted = false and temp = false and approved = true and campagne_id in (select id from campagne where deleted = false and anno = ?) group by id_plot order by id_plot) as temp
      on plot.id_plot = temp.id_plot
    where deleted = false and id in (select plot_id from erbacee where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) or id  in (select plot_id from legnose where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) order by id_plot",@anno,@anno,@anno]

    #DA TENERE
    copbrio = Erbacee.find_by_sql ["select numero_plot,plot.id_plot,copbrio
    from plot left join (select id_plot, sum(copertura) as copbrio from erbacee,specie,euflora where specie_id is not null and specie_id = specie.id and euflora_id = euflora.id and (codice_eu regexp '^3' or codice_eu regexp '^4') and erbacee.deleted = false and temp = false and approved = true and campagne_id in (select id from campagne where deleted = false and anno = ?) group by id_plot order by id_plot) as temp
	    on plot.id_plot = temp.id_plot
    where deleted = false and id in (select plot_id from erbacee where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) or id  in (select plot_id from legnose where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) order by id_plot",@anno,@anno,@anno]

    #DA TENERE
    coplich = Erbacee.find_by_sql ["select numero_plot,plot.id_plot,coplich
    from plot left join (select id_plot, sum(copertura) as coplich from erbacee,specie,euflora where specie_id is not null and specie_id = specie.id and euflora_id = euflora.id and (codice_eu regexp '^5' or codice_eu regexp '^6' or codice_eu regexp '^7') and erbacee.deleted = false and temp = false and approved = true and campagne_id in (select id from campagne where deleted = false and anno = ?) group by id_plot order by id_plot) as temp
	    on plot.id_plot = temp.id_plot
    where deleted = false and id in (select plot_id from erbacee where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) or id  in (select plot_id from legnose where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) order by id_plot",@anno,@anno,@anno]

    #DA TENERE
    copleg = Legnose.find_by_sql ["select numero_plot,plot.id_plot,copleg
    from plot left join (select id_plot,sum(copertura) as copleg from legnose where specie_id is not null and deleted = false and temp = false and approved = true and campagne_id in (select id from campagne where deleted = false and anno = ?) group by id_plot order by id_plot) as temp
	    on plot.id_plot = temp.id_plot
    where deleted = false and id in (select plot_id from erbacee where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) or id  in (select plot_id from legnose where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) order by id_plot",@anno,@anno,@anno]

    #DA TENERE
    nspecerb = Erbacee.find_by_sql ["select numero_plot,plot.id_plot,nspecerb
    from plot left join (select id_plot, count(distinct specie_id) as nspecerb from erbacee,specie,euflora where specie_id is not null and specie_id = specie.id and euflora_id = euflora.id and (codice_eu regexp '^0' or codice_eu regexp '^1' or codice_eu regexp '^2') and erbacee.deleted = false and temp = false and approved = true and campagne_id in (select id from campagne where deleted = false and anno = ?) group by id_plot order by id_plot) as temp
	    on plot.id_plot = temp.id_plot
    where deleted = false and id in (select plot_id from erbacee where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) or id  in (select plot_id from legnose where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) order by id_plot",@anno,@anno,@anno]

    #DA TENERE
    nspecbrio = Erbacee.find_by_sql ["select numero_plot,plot.id_plot,nspecbrio
    from plot left join (select id_plot, count(distinct specie_id) as nspecbrio from erbacee,specie,euflora where specie_id is not null and specie_id = specie.id and euflora_id = euflora.id and (codice_eu regexp '^3' or codice_eu regexp '^4') and erbacee.deleted = false and temp = false and approved = true and campagne_id in (select id from campagne where deleted = false and anno = ?) group by id_plot order by id_plot) as temp
	    on plot.id_plot = temp.id_plot
    where deleted = false and id in (select plot_id from erbacee where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) or id  in (select plot_id from legnose where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) order by id_plot",@anno,@anno,@anno]

    #DA TENERE
    nspeclich = Erbacee.find_by_sql ["select numero_plot,plot.id_plot,nspeclich
    from plot left join (select id_plot, count(distinct specie_id) as nspeclich from erbacee,specie,euflora where specie_id is not null and specie_id = specie.id and euflora_id = euflora.id and (codice_eu regexp '^5' or codice_eu regexp '^6' or codice_eu regexp '^7') and erbacee.deleted = false and temp = false and approved = true and campagne_id in (select id from campagne where deleted = false and anno = ?) group by id_plot order by id_plot) as temp
	    on plot.id_plot = temp.id_plot
    where deleted = false and id in (select plot_id from erbacee where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) or id  in (select plot_id from legnose where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) order by id_plot",@anno,@anno,@anno]

    #DA TENERE
    nspecleg = Legnose.find_by_sql ["select numero_plot,plot.id_plot,nspecleg
    from plot left join (select id_plot,count(distinct specie_id) as nspecleg from legnose where specie_id is not null and deleted = false and temp = false and approved = true and campagne_id in (select id from campagne where deleted = false and anno = ?) group by id_plot order by id_plot) as temp
	    on plot.id_plot = temp.id_plot
    where deleted = false and id in (select plot_id from erbacee where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) or id  in (select plot_id from legnose where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) order by id_plot",@anno,@anno,@anno]

    if plot.blank?
      render :update do |page|
        page.replace_html "eu", "Nessun dato con cui effettuare la statistica."
      end
    else
      @eu_list = format_data(plot,unita,niferb,nifleg,coperb,copbrio,coplich,copleg,nspecerb,nspecbrio,nspeclich,nspecleg)
      @file = regular_file(@eu_list)
      render :update do |page|
        page.replace_html "eu", :partial => "eu_summary", :object => [@eu_list,@file]
      end
    end

  end

  private

  def format_data(plot,unita,niferb,nifleg,coperb,copbrio,coplich,copleg,nspecerb,nspecbrio,nspeclich,nspecleg)
   list = Array.new
    for i in 0..plot.size-1
      eu = EuStat.new
      eu.set_nplot(plot.at(i))
      eu.set_unita(unita.at(i))
      eu.set_niferb(niferb.at(i))
      eu.set_nifleg(nifleg.at(i))
      eu.set_coperb(coperb.at(i))
      eu.set_copbrio(copbrio.at(i))
      eu.set_coplich(coplich.at(i))
      eu.set_copleg(copleg.at(i))
      eu.set_nspecerb(nspecerb.at(i))
      eu.set_nspecbrio(nspecbrio.at(i))
      eu.set_nspeclich(nspeclich.at(i))
      eu.set_nspecleg(nspecleg.at(i))

      list << eu
    end
    return list
  end


  def regular_file(content)
    #creo il nuovo documento
    eu_file = Spreadsheet::Workbook.new
    #aggiungo un nuovo foglio di lavoro
    sheet1 = eu_file.create_worksheet :name => 'Foglio di lavoro 1'
    #nella prima riga metto le intestazioni
    sheet1[0,0] = "nplot"
    sheet1[0,1] = "unita"
    sheet1[0,2] = "niferb"
    sheet1[0,3] = "nifleg"
    sheet1[0,4] = "coperb"
    sheet1[0,5] = "copbrio"
    sheet1[0,6] = "coplich"
    sheet1[0,7] = "copleg"
    sheet1[0,8] = "nspecerb"
    sheet1[0,9] = "nspecbrio"
    sheet1[0,10] = "nspeclich"
    sheet1[0,11] = "nspecleg"

    #aggiungo tutti i dati
    for i in 0..content.size-1
      sheet1[i+1,0] = content.at(i).nplot
      sheet1[i+1,1] = content.at(i).unita
      sheet1[i+1,2] = content.at(i).niferb
      sheet1[i+1,3] = content.at(i).nifleg
      sheet1[i+1,4] = content.at(i).coperb
      sheet1[i+1,5] = content.at(i).copbrio
      sheet1[i+1,6] = content.at(i).coplich
      sheet1[i+1,7] = content.at(i).copleg
      sheet1[i+1,8] = content.at(i).nspecerb
      sheet1[i+1,9] = content.at(i).nspecbrio
      sheet1[i+1,10] = content.at(i).nspeclich
      sheet1[i+1,11] = content.at(i).nspecleg

    end

    #formattazione file
    bold = Spreadsheet::Format.new :weight => :bold
    12.times do |x| sheet1.row(0).set_format(x, bold) end

    #creo la directory
    dir = "#{RAILS_ROOT}/public/Eu Summary/"
    #imposto il nome del file
    file_name = "eu.xls"
    #imposto il full_path e la relative_path
    full_path = dir + file_name
    relative_path = "/Eu Summary/#{file_name}"
    require 'ftools'
    File.makedirs dir
    #scrivo il file
    eu_file.write "#{RAILS_ROOT}/public/Eu Summary/#{file_name}"
    #creo l'oggetto file
    new_stat_file = OutputFile.new
    new_stat_file.fill(file_name,full_path,relative_path,"Eu Sum")
    return new_stat_file
  end

end
