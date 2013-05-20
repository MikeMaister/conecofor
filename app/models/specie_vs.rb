class SpecieVs < ActiveRecord::Base
  set_table_name "specie_vs"

  #è per la ridondanza
  before_save :set_listspe
  validates_presence_of :species,:listspe_id ,:message => "non può essere vuoto."
  validates_length_of :species,:maximum => 200,:message => "massimo 200 caratteri."
  validate :no_dup

  def no_dup
    #carico tutte le specie europee non eliminate
    spe_vs_list = SpecieVs.find(:all, :conditions => "deleted = false")
    unless spe_vs_list.blank?
      #per ogni specie
      spe_vs_list.each do |vs|
        if vs.species.capitalize == species.capitalize && vs.id != self.id && !species.blank?
          #segnalo l'errore
          errors.add(:species, " già presente tra le specie vs.")
        end
      end
    end
  end

  def get_vs
    return "" + self.listspe + " - " + self.species
  end

  def update_specie_vs(spe,listspe_id)
    self.species = spe
    self.listspe_id = listspe_id
    return true if self.save
  end

  def delete_it!
    self.deleted = true
    delete_dependencies(self.id)
    self.save
  end



  private

  def set_listspe
    self.listspe = Listspe.find(listspe_id).listspe
  end

  def delete_dependencies(id)
    #sganciare anche quelle eliminate
    euflora = Euflora.find(:all,:conditions => ["specie_vs_id = ?",id])
    unless euflora.blank?
      for i in 0..euflora.size-1
        euflora.at(i).unlink_specie_vs!
      end
    end
  end

end
