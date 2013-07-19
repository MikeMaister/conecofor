class Vs #< ActiveRecord::Base
  attr_accessor :subprog,:area,:inst,:scode,:medium,:listmed,
                :size,:yyyymm,:spool,:pflag,:species,:listspe,
                :class,:param,:parlist,:value,:unit,:flagqua,:flagsta

  def initialize(record)
    #vs_spec = get_specie_vs(record)

    @subprog = "VS"
    @area = Plot.find(record.plot_id).im
    @inst = "UC"
    @scode = nil
    @medium = nil
    @listmed = "IT"
    @size = nil
    @yyyymm = record.data.strftime("%Y%m")
    @spool = record.subplot
    @pflag = nil
    @species = record.specie_vs #vs_spec.species if vs_spec
    @listspe = record.listspe #vs_spec.listspe if vs_spec
    @class = nil
    @param = get_param(record.codice_strato)
    @parlist = "IM"
    @value = CoperturaSpecifica.find(record.copertura_specifica_id).value unless record.copertura_specifica_id.blank?
    @unit = "%"
    @flagqua = nil
    @flagsta = nil
  end

  private

  def get_param(cod_strato)
    case cod_strato
      when 1
        param = "COVE_T"
      when 2
        param = "COVE_S"
      when 3
        param = "COVE_F"
      when 4
        param = "COVE_B"
    end
    return param
  end

  def get_specie_vs(record)
    #carico la corrispettiva specie pignatti a meno che non esista nel record
    pignatti = Specie.find(record.specie_id) unless record.specie_id.blank?
    #carico la corrispettiva specie euflora a meno che non esista in pignatti
    euflora = Euflora.find(pignatti.euflora_id) unless pignatti.blank? || pignatti.euflora_id.blank?
    #carico la corrispettiva specie vs a meno che non esista in euflora
    specie_vs = SpecieVs.find(euflora.specie_vs_id) unless euflora.blank? || euflora.specie_vs_id.blank?

    return specie_vs
  end

end
