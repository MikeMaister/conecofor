class Specie < ActiveRecord::Base
  set_table_name "specie"

  validates_presence_of :descrizione, :message => "non può essere vuoto."
  validates_length_of :descrizione, :maximum => 100 , :message => "massimo 100 caratteri."
  validate :no_dup

  def no_dup
    #carico tutte le specie non eliminate
    specie_list = Specie.find(:all, :conditions => "deleted = false")
    unless specie_list.blank?
      #per ogni plot
      specie_list.each do |spec|
        if spec.descrizione.capitalize == descrizione.capitalize && spec.id != self.id
          #segnalo l'errore
          errors.add(:descrizione, " già presente tra le specie.")
        end
      end
    end
  end

  def update_specie(desc,euflora)
    self.descrizione = desc
    self.euflora_id = euflora
    return true if self.save
  end

  def delete_it!
    self.deleted = true
    delete_dependencies(self.id)
    self.save
  end

  private

  def delete_dependencies(specie_id)
    #COPS
    cops = Cops.find(:all,:conditions => ["deleted = false AND specie_id = ?",specie_id])
    unless cops.blank?
      for i in 0..cops.size-1
        cops.at(i).delete_it!
      end
    end
    #LEGNOSE
    legn = Legnose.find(:all,:conditions => ["deleted = false AND specie_id = ?",specie_id])
    unless legn.blank?
      for i in 0..legn.size-1
        legn.at(i).delete_it!
      end
    end
    #ERBACEE
    erb = Erbacee.find(:all, :conditions => ["deleted = false AND specie_id = ?",specie_id])
    unless erb.blank?
      for i in 0..erb.size-1
        erb.at(i).delete_it!
      end
    end
  end

end
