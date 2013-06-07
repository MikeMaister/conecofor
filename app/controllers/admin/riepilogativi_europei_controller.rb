class Admin::RiepilogativiEuropeiController < ApplicationController

  def index
    @anno = Campagne.find_by_sql "SELECT DISTINCT(anno) FROM campagne WHERE deleted = false ORDER BY anno"
  end

  def result
    @anno = params[:anno]

    @plot = Plot.find_by_sql ["select numero_plot from plot where deleted = false and id in (select plot_id from erbacee where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false)) or id  in (select plot_id from legnose where specie_id is not null and deleted = false and approved = true and temp = false and campagne_id in (select id from campagne where anno = ? and deleted = false))",@anno,@anno]

    @result = ActiveRecord::Base.connection.execute("select id_plot,count(subplot) as n_su from
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
      as temp group by id_plot")

    render :update do |page|
      page.replace_html "eu", :partial => "eu_summary", :object => [@plot,@result]
    end
  end

end
