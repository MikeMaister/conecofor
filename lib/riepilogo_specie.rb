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

end