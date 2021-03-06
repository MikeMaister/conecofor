class Developer::UpdateEufloraController < ApplicationController

  def prova
    require 'will_paginate'
    @asd = Euflora.paginate(:page => params[:page], :per_page => 30)
  end


  def update

    #carico tutte le specie euflora
    @euflora = Euflora.find(:all, :conditions => "deleted = false")
    #carico tutte le specie pignatti
    @pignatti = Specie.find(:all, :conditions => "deleted = false")

    require 'rubygems'
    gem 'ruby-ole','1.2.11.4'
    require 'spreadsheet'

    #path verso il file di aggiornamento
    pignatti_exception = Spreadsheet.open 'C:/Users/MikeMaister/RubymineProjects/conecofor/public/link euflora_pignatti/corrispondenze flora.xls'
    #imposto il foglio di lavoro
    sheet = pignatti_exception.worksheet 0

    #scorro tutte le righe del file
    sheet.each_with_index do |row,i|
      # a meno che l'intera riga non sia vuota (EOF)
      unless row[0].blank? && row[1].blank?
        #fa saltare la prima riga
        if i != 0
          #cerco il record pignatti corrispondente alla descrizione
          p_record = Specie.find(:first, :conditions => ["descrizione = ? AND deleted = false",row[0]])
          #cerco il record euflora corrispondente alla descrizione
          eu_record = Euflora.find(:first,:conditions => ["descrizione = ? AND deleted = false",row[1]])
          unless p_record.blank? || eu_record.blank?
            p_record.euflora_id = eu_record.id
            p_record.save
          end
        end
      end
    end

    #carico le rimanenti
    for i in 0..@pignatti.size-1
      for j in 0..@euflora.size-1
        if @pignatti.at(i).euflora_id.nil? && @pignatti.at(i).descrizione.capitalize == @euflora.at(j).descrizione.capitalize
          @pignatti.at(i).euflora_id = @euflora.at(j).id
          @pignatti.at(i).save
          break
        end
      end
    end

  end

  def link_eu_species_vs
    @euflora = Euflora.find(:all,:conditions => "deleted = false")
    @vs = SpecieVs.find(:all,:conditions => "deleted = false")

    for i in 0..@euflora.size-1
      for j in 0..@vs.size-1
        if @euflora.at(i).descrizione.capitalize == @vs.at(j).descrizione.capitalize
          @euflora.at(i).specie_vs_id = @vs.at(j).id
          @euflora.at(i).save
          break
        end
      end
    end

  end


end
