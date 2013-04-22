class Vs #< ActiveRecord::Base
  attr_accessor :subprog,:area,:inst,:scode,:medium,:listmed,
                :size,:yyymm,:spool,:pflag,:species,:listspe,
                :class,:param,:parlist,:value,:unit,:flagqua,:flagsta

  def initialize(record)
    @subprog = "VS"
    @area = Plot.find(record.plot_id).im
    @inst = "UC"
    @scode = nil
    @medium = nil
    @listmed = "IT"
    @size = nil
    @yyymm = record.data.strftime("%Y/%m")
    @spool = record.subplot
    @pflag = nil
    @species
    @listspe
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

end
