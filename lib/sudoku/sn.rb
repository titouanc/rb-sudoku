module Sudoku
  #Generic adapter
  class Sn
    include Grid
    attr_reader :size
    
    def initialize n=3
      @base   = n.to_i
      @size   = @base*@base
      @length = @size*@size
      @grid = Array.new(@size) do |i|
        Array.new(@size){|j| 0}
      end
    end
    
    def set x, y, val
      @grid[x][y] = val
    end
    
    def get x, y
      @grid[x][y]
    end
    
    def each
      @size.times do |y|
        @size.times do |x|
          yield x, y, @grid[x][y]
        end
      end
    end
  end
end