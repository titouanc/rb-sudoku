require "sudokucore"

module Sudoku
  #Optimized [4,15]x[4,15] Sudoku
  class S4_15
    include Grid
    private :size_internal
    
    def size
      if @size
        @size
      else
        @size = size_internal
      end
    end
  end
end