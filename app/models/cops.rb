class Cops < ActiveRecord::Base
  set_table_name "cops"

  def fill_temp(record,file_id,row)
    #pre-carico quello che mi serve evitando di fallo svariate volte
    file = ImportFile.find(file_id)
    plot = Plot.find(:first,:conditions => ["numero_plot = ? AND deleted = false", record.cod_plot])
    pignatti = Specie.find(:first, :conditions => ["descrizione = ? AND deleted = false", record.specie]) unless record.specie.blank?
    unless pignatti.blank?
      unless pignatti.euflora_id.blank?
        euflora = Euflora.find(pignatti.euflora_id)
        unless euflora.blank?
          unless euflora.specie_vs_id.blank?
            specie_vs = SpecieVs.find(euflora.specie_vs_id)
          end
        end
      end
    end

    self.id_plot = plot.id_plot
    self.subplot = record.subplot
    self.in_out = record.in_out
    self.priest = record.priest
    self.codice_strato = record.cod_strato
    self.copertura_specifica_id = CoperturaSpecifica.find(:first,:conditions => ["identifier = ?",record.copertura]).id
    self.note = record.note
    self.data = record.data
    self.campagne_id = file.campagne_id
    self.specie_id = pignatti.id #Specie.find(:first, :conditions => ["descrizione = ? AND deleted = false", record.specie]).id unless record.specie.blank?
    self.plot_id = plot.id
    self.numero_plot = record.cod_plot
    self.temp = true
    self.row = row
    self.file_name_id = file_id
    self.import_num = file.import_num
    self.approved = false
    self.substrate_type_id = SubstrateType.find(:first, :conditions => ["code = ?",record.substrate]).id if !record.substrate.blank?
    self.certainty_species_determination_id = CertaintySpeciesDetermination.find(:first, :conditions => ["code = ?",record.certainty_species_determination]).id if !record.certainty_species_determination.blank?
    self.deleted = false
    self.descrizione_pignatti = pignatti.descrizione unless pignatti.blank?
    self.codice_europeo = euflora.codice_eu unless euflora.blank?
    self.descrizione_europea = euflora.descrizione unless euflora.blank?
    self.specie_vs = specie_vs.species unless specie_vs.blank?
    self.listspe = specie_vs.listspe unless specie_vs.blank?
    self.save
  end

  def permanent!
    self.temp = false
    self.save
  end

  def approve_it!
    self.approved = true
    self.save
  end

  def delete_it!
    self.deleted = true
    self.save
  end

  def set_habitual_note(giustifica)
    self.habitual_specie_note = giustifica
    self.save
  end

end

