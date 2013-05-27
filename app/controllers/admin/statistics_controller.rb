class Admin::StatisticsController < ApplicationController

  def index
    @plot = Plot.find(:all,:conditions => "deleted = false")
    @anno = Campagne.find_by_sql "SELECT DISTINCT(anno) FROM campagne WHERE deleted = false ORDER BY anno"

  end

  def update_field
    survey = params[:selected_survey]
    case survey
      when "erb"
        render :update do |page|
          page.replace_html "select_field", :partial => "erb_field"
        end
      when "leg"
      when "cops"
      when "copl"
      else
    end
  end

  def result
    @survey = params[:survey]
    @field = params[:field]
    @plot = params[:plot]
    @anno = params[:anno]
    @stats = Statistic.new
    if @plot == "all"
      @stats.all_plot(@survey,@field,@anno)
    else
      @stats.single_plot(@survey,@field,@plot,@anno)
    end
    render :update do |page|
      page.replace_html "stat", :partial => "stats", :object => [@survey,@field,@plot,@anno,@stats]
    end
  end





end
