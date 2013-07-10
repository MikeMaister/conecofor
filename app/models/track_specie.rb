class TrackSpecie < ActiveRecord::Base
  set_table_name "track_specie"

  def fill_and_save!(pignatti,euflora)
    self.spe_desc = pignatti.descrizione
    self.data = DateTime.now
    self.codice_eu = euflora.codice_eu
    self.eu_fam = euflora.famiglia
    self.eu_desc = euflora.descrizione
    self.eu_spe = euflora.specie
    self.specie_id = pignatti.id
    self.save
  end

  def no_eu_fill_and_save!(pignatti)
    self.spe_desc = pignatti.descrizione
    self.data = DateTime.now
    self.codice_eu = nil
    self.eu_fam = nil
    self.eu_desc = nil
    self.eu_spe = nil
    self.specie_id = pignatti.id
    self.save
  end

end
