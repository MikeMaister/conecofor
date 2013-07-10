class TrackEuflora < ActiveRecord::Base
  set_table_name "track_euflora"

  def fill_and_save!(euflora,specie_vs,list_spe)
    self.data = DateTime.now
    self.codice_eu = euflora.codice_eu
    self.famiglia = euflora.famiglia
    self.descrizione = euflora.descrizione
    self.specie = euflora.specie
    self.euflora_id = euflora.id
    self.vs_species = specie_vs.species
    self.vs_listspe = specie_vs.listspe
    self.vs_descrizione = specie_vs.descrizione
    self.listspe = list_spe.listspe
    self.save
  end

  def no_vs_fill_and_save!(euflora)
    self.data = DateTime.now
    self.codice_eu = euflora.codice_eu
    self.famiglia = euflora.famiglia
    self.descrizione = euflora.descrizione
    self.specie = euflora.specie
    self.euflora_id = euflora.id
    self.vs_species = nil
    self.vs_listspe = nil
    self.vs_descrizione = nil
    self.listspe = nil
    self.save
  end

end
