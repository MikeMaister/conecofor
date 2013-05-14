class SpecieVs < ActiveRecord::Base
  set_table_name "specie_vs"

  #attr_accessor :species, :listspe, :descrizione

  def get_vs
    return "" + self.listspe + " - " + self.species
  end


end
