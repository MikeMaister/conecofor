class Campagne < ActiveRecord::Base
  set_table_name "campagne"

  attr_accessible :season_id,:inizio,:fine,:note,:active,:note_stagione,:deleted,:descrizione

  validates_presence_of :season_id,:inizio,:fine , :message => "non può essere vuoto."
  validates_length_of :note,:note_stagione, :maximum => 500 , :message => "massimo 500 caratteri."
  validate :inizio_before_fine, :unless => "inizio.blank? || fine.blank?"
  validate :date_season, :unless => "inizio.blank? || fine.blank? || season_id.blank?"
  validate :no_dup, :unless => "season_id.blank? || inizio.blank?"

  def no_dup
    dup = Campagne.find(:first,:conditions => ["descrizione = ? AND deleted = 0",descrizione])
    unless dup.blank?
      #serviva per distinguere lo stesso record
      #if dup.id != id
        errors.add(:descrizione, "Campagna già esistente.")
      #end
    end
  end

  def inizio_before_fine
      if inizio > fine
        errors.add(:inizio, "non può essere successivo a fine.")
      end
  end

  def date_season
    stagione = Season.find(season_id)
    unless (inizio.month > stagione.inizio.month && fine.month < stagione.fine.month) || (inizio.month == stagione.inizio.month && inizio.day >= stagione.inizio.day) || (fine.month == stagione.fine.month && fine.day <= stagione.fine.day)
      if note_stagione.blank?
        errors.add(:note_stagione, "deve essere compilata, in quanto la stagione dichiarata non corrisponde alla stagione effettiva corrispondente, alla data selezionata.")
      end
    end
  end

  def fill(stagione,inizio,fine,note,note_stagione)
    self.season_id = stagione
    self.inizio = inizio
    self.fine = fine
    self.note = note
    self.active = false
    self.note_stagione = note_stagione
    self.descrizione = set_descrizione(self.season_id,self.inizio)
    self.deleted = false
    self.anno = self.inizio.year unless self.inizio.blank?
  end

  #attiva campagna
  def active_it
    self.update_attribute(:active,true)
  end

  #disattiva campagna
  def deactivate_it
    self.update_attribute(:active,false)
  end

  #elimina campagna
  def delete_it
    self.update_attribute(:deleted,true)
    delete_cops_dependencies(self.id)
    delete_copl_dependencies(self.id)
    delete_erb_dependencies(self.id)
    delete_legn_dependencies(self.id)
    delete_srm_dependencies(self.id)
    delete_mm_dependencies(self.id)
    return true
  end

  private

  def set_descrizione(season_id,inizio)
    unless season_id.blank? || inizio.blank?
      desc = "#{Season.find(self.season_id).nome} #{self.inizio.year}"
      return desc
    end
  end

  def delete_cops_dependencies(camp_id)
    #trovo tutti i record immessi correttamente
    cops_dep = Cops.find(:all, :conditions => ["campagne_id = ?", camp_id])
    unless cops_dep.blank?
      cops_dep.each do |copsd|
        #li elimino
        copsd.delete_it!
      end
    end
    #trovo i file cops importati
    cops_file_dep = ImportFile.find(:all, :conditions => ["campagne_id = ?",camp_id])
    unless cops_file_dep.blank?
      cops_file_dep.each do |cfd|
        #invalido il file
        cfd.delete_it!
        #per ogni file trovo tutti gli errori
         cops_error_dep = ErrorCops.find(:all,:conditions => ["file_name_id = ?",cfd.id])
         unless cops_error_dep.blank?
           cops_error_dep.each do |ced|
             #li invalido
             ced.delete_it!
           end
         end
      end
    end
  end

  #i nomi delle variabili sono come quelle per cops ma non fa nulla
  def delete_copl_dependencies(camp_id)
    #trovo tutti i record immessi correttamente
    cops_dep = Copl.find(:all, :conditions => ["campagne_id = ?", camp_id])
    unless cops_dep.blank?
      cops_dep.each do |copsd|
        #li elimino
        copsd.delete_it!
      end
    end
    #trovo i file cops importati
    cops_file_dep = ImportFile.find(:all, :conditions => ["campagne_id = ?",camp_id])
    unless cops_file_dep.blank?
      cops_file_dep.each do |cfd|
        #invalido il file
        cfd.delete_it!
        #per ogni file trovo tutti gli errori
        cops_error_dep = ErrorCopl.find(:all,:conditions => ["file_name_id = ?",cfd.id])
        unless cops_error_dep.blank?
          cops_error_dep.each do |ced|
            #li invalido
            ced.delete_it!
          end
        end
      end
    end
  end

  #i nomi delle variabili sono come quelle per cops ma non fa nulla
  def delete_erb_dependencies(camp_id)
    #trovo tutti i record immessi correttamente
    cops_dep = Erbacee.find(:all, :conditions => ["campagne_id = ?", camp_id])
    unless cops_dep.blank?
      cops_dep.each do |copsd|
        #li elimino
        copsd.delete_it!
      end
    end
    #trovo i file cops importati
    cops_file_dep = ImportFile.find(:all, :conditions => ["campagne_id = ?",camp_id])
    unless cops_file_dep.blank?
      cops_file_dep.each do |cfd|
        #invalido il file
        cfd.delete_it!
        #per ogni file trovo tutti gli errori
        cops_error_dep = ErrorErbacee.find(:all,:conditions => ["file_name_id = ?",cfd.id])
        unless cops_error_dep.blank?
          cops_error_dep.each do |ced|
            #li invalido
            ced.delete_it!
          end
        end
      end
    end
  end

  #i nomi delle variabili sono come quelle per cops ma non fa nulla
  def delete_legn_dependencies(camp_id)
    #trovo tutti i record immessi correttamente
    cops_dep = Legnose.find(:all, :conditions => ["campagne_id = ?", camp_id])
    unless cops_dep.blank?
      cops_dep.each do |copsd|
        #li elimino
        copsd.delete_it!
      end
    end
    #trovo i file cops importati
    cops_file_dep = ImportFile.find(:all, :conditions => ["campagne_id = ?",camp_id])
    unless cops_file_dep.blank?
      cops_file_dep.each do |cfd|
        #invalido il file
        cfd.delete_it!
        #per ogni file trovo tutti gli errori
        cops_error_dep = ErrorLegnose.find(:all,:conditions => ["file_name_id = ?",cfd.id])
        unless cops_error_dep.blank?
          cops_error_dep.each do |ced|
            #li invalido
            ced.delete_it!
          end
        end
      end
    end
  end

  def delete_mm_dependencies(camp_id)
    #trovo tutte le dipendenze
    mm_association = MandatoryMaskAssociation.find(:all, :conditions => ["campagna_id = ? AND deleted = false",camp_id])
    #a meno che non ne abbia
    unless mm_association.blank?
      #scorro tutte le associazioni
      mm_association.each do |mma|
        #le cancello
        mma.delete_it!
      end
    end
  end

  def delete_srm_dependencies(camp_id)
    #trovo tutte le dipendenze
    srm_association = SimpleRangeAssociation.find(:all, :conditions => ["campagna_id = ? AND deleted = false",camp_id])
    #a meno che non ne abbia
    unless srm_association.blank?
      #scorro tutte le associazioni
      srm_association.each do |srma|
        #le cancello
        srma.delete_it!
      end
    end
  end

end
