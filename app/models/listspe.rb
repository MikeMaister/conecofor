class Listspe < ActiveRecord::Base
  set_table_name "listspe"

  validates_presence_of :listspe, :message => "non può essere vuota."
  validates_length_of :listspe, :maximum => 20 , :message => "massimo 20 caratteri."
  validate :no_dup

  def no_dup
    all_listspe = Listspe.find(:all,:conditions => "deleted = false")
    unless all_listspe.blank?
      #per ogni specie
      all_listspe.each do |ls|
        if ls.listspe.capitalize == listspe.capitalize && ls.id != self.id
          #segnalo l'errore
          errors.add(:listspe, " già presente tra le listspe.")
        end
      end
    end
  end

  def update_listspe(listspe)
    self.listspe = listspe
    self.save
  end

  def delete_it!
    self.deleted = true
    delete_dependencies(self.id)
    self.save
  end

  private

  def delete_dependencies(id)
    vs_spe = SpecieVs.find(:all,:conditions => ["listspe_id = ?",id])
    unless vs_spe.blank?
      vs_spe.each do |vs|
        vs.delete_it!
      end
    end
  end

end
