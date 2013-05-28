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
        render :update do |page|
          page.replace_html "select_field", :partial => "leg_field"
        end
      when "cops"
        render :update do |page|
          page.replace_html "select_field", :partial => "cops_field"
        end
      when "copl"
      else
    end
  end

  def result
    @survey = params[:survey]
    @field = params[:field]
    @plot = params[:plot]
    @anno = params[:anno]
    @inout = params[:inout]
    @priest = params[:priest]
    @cod_strato = params[:cod_stra]
    @specie = params[:specie]

    #se è un record su un plot singolo semplice leg
    if (@survey == "leg" && @plot != "all")  || (@survey == "erb" && @field != "nif" && @plot != "all")
      @stats = Statistic.new
      @stats.single_plot(@survey,@field,@plot,@anno)
      render :update do |page|
        page.replace_html "stat", :partial => "stats", :object => [@survey,@field,@plot,@anno,@stats,@inout,@priest,@cod_strato,@specie]
      end
    #se è un record su un plot ma erb --> nif
    elsif @survey == "erb" && @field == "nif" && @plot != "all"
      @stats = Erbstat.new
      @stats.single_plot(@plot,@anno)
      render :update do |page|
        page.replace_html "stat", :partial => "stats", :object => [@survey,@field,@plot,@anno,@stats,@inout,@priest,@cod_strato,@specie]
      end
    #se è un record su un plot di tipo cops senza l'aggiunta di altri filtri
    elsif @survey == "cops" && @plot != "all" && @inout.blank? && @priest.blank? && @cod_strato.blank? && @specie.blank?
      @stats = Statistic.new
      @stats.single_plot(@survey,@field,@plot,@anno)
      render :update do |page|
        page.replace_html "stat", :partial => "stats", :object => [@survey,@field,@plot,@anno,@stats,@inout,@priest,@cod_strato,@specie]
      end
    #se è un record su un plot di tipo cops con uno o più filtri aggiunti
    elsif @survey == "cops" && @plot != "all" && (@inout.to_i == 1 || @priest.to_i == 1 || @cod_strato.to_i == 1 || @specie.to_i == 1)
      @query_part = Copsstat.new
      @query_part.query_build(@inout,@priest,@cod_strato,@specie)
      @stats = Copsstat.new
      @stats.cops_filter(@field,@plot,@anno,@query_part)
      render :update do |page|
        page.replace_html "stat", :partial => "prova", :object => [@survey,@field,@plot,@anno,@inout,@priest,@cod_strato,@specie,@query_part,@stats]
      end
    end


  end





end
