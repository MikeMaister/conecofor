module Riepilogo_specie

  class FiftyXFifty
    attr_accessor :plot_column,:specie_column,:presenza_list_column
    def initialize(plot,specie_list)
      @plot_column = plot
      @specie_column = specie_list
      @presenza_list_column = Array.new
    end
  end

  class Presenza
    attr_accessor :presenza_column, :anno
    def initialize(specie_list,year)
      @presenza_column = specie_list
      @anno = year
    end
  end

  class TenXTen
    attr_accessor :plot_column,:specie_pri_in,:pres_list_col_pi,
                  :specie_est_out,:pres_list_col_po,
                  :specie_est_in,:pres_list_col_ei,
                  :specie_est_out,:pres_list_col_eo
    def initialize(plot,spi,spo,sei,seo)
      @plot_column = plot
      @specie_pri_in = spi
      @pres_list_col_pi = Array.new
      @specie_pri_out = spo
      @pres_list_col_po = Array.new
      @specie_est_in = sei
      @pres_list_col_ei = Array.new
      @specie_est_out = seo
      @pres_list_col_eo = Array.new
    end
  end

end