require "sudokucore"

module Sudoku
  #Highly optimized 9x9 Sudoku
  class S3
    include Grid
    
    def size
      SIZE
    end
  end
end