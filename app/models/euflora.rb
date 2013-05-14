class Euflora < ActiveRecord::Base
  set_table_name "euflora"

  validates_presence_of :descrizione,:codice_eu,:famiglia,:specie ,:message => "non può essere vuoto."
  validates_length_of :descrizione, :maximum => 100, :message => "massimo 100 caratteri."
  validates_length_of :famiglia,:specie, :maximum => 50,:message => "massimo 50 caratteri."
  validates_format_of :codice_eu, :with => /^\d{3}\.\d{3}\.\d{3}$/, :message => "formato non valido."
end
