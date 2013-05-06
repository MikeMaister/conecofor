class Developer::UpdateEufloraController < ApplicationController

  def update

    #carico tutte le specie euflora
    @euflora = Euflora.find(:all)
    #carico tutte le specie pignatti
    @pignatti = Specie.find(:all)

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
          p_record = Specie.find(:first, :conditions => ["descrizione = ?",row[0]])
          #cerco il record euflora corrispondente alla descrizione
          eu_record = Euflora.find(:first,:conditions => ["descrizione = ?",row[1]])
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

end
