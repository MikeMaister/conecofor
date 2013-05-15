class Euflora < ActiveRecord::Base
  set_table_name "euflora"

  validates_presence_of :descrizione,:codice_eu,:famiglia,:specie ,:message => "non può essere vuoto."
  validates_length_of :descrizione, :maximum => 100, :message => "massimo 100 caratteri."
  validates_length_of :famiglia,:specie, :maximum => 50,:message => "massimo 50 caratteri."
  validates_format_of :codice_eu, :with => /^\d{3}\.\d{3}\.\d{3}$/, :message => "formato non valido."
  validate :no_dup

  #controlla che ne il codice europeo ne la descrizione siano duplicati
  def no_dup
    #carico tutte le specie europee non eliminate
    eu_list = Euflora.find(:all)#, :conditions => "deleted = false")
    unless eu_list.blank?
      #per ogni specie
      eu_list.each do |eu|
        if eu.descrizione.capitalize == descrizione.capitalize && eu.id != self.id
          #segnalo l'errore
          errors.add(:descrizione, " già presente tra le specie europee.")
        end
        if eu.codice_eu == codice_eu && eu.id != self.id
          #segnalo l'errore
          errors.add(:codice_eu, " già assegnato.")
        end
      end
    end
  end


  def update_eu(eucod,desc,fam,spe,vsspe)
    self.codice_eu = eucod
    self.descrizione = desc
    self.famiglia = fam
    self.specie = spe
    self.specie_vs_id = vsspe
    return true if self.save
  end

end
