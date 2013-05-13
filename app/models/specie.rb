class Specie < ActiveRecord::Base
  set_table_name "specie"

  validates_presence_of :descrizione, :message => "non può essere vuoto."
  validates_length_of :descrizione, :maximum => 100 , :message => "massimo 100 caratteri."
  validate :no_dup

  def no_dup
    #carico tutti i plot non eliminati
    specie_list = Specie.find(:all)
    unless specie_list.blank?
      #per ogni plot
      specie_list.each do |spec|
        if spec.descrizione == descrizione && spec.id != self.id
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
end
