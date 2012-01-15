require "#{File.dirname __FILE__}/ext/sudoku"

module Sudoku
  #Common tasks
  module Grid
    #returns content of column +x+ as an Array
    def col x
      res = []
      size.times do |y|
        val = get x, y
        res << val if val != 0
      end
      res
    end
    
    #returns content of row +y+ as an Array
    def row y 
      res = []
      size.times do |x|
        val = get x, y
        res << val if val != 0
      end
      res
    end
    
    #returns content of square enclosing +xx+,+yy+ as an Array
    def square xx, yy
      xmin = xx/base
      ymin = yy/base
      res = []
      
      base.times do |x|
        base.times do |y|
          val = get x+xmin, y+ymin
          res << val if val != 0
        end
      end
      
      res
    end
    
    #returns sudoku base (little square size)
    def base
      if @base
        @base
      else
        @base = (size**0.5).to_i
      end
    end
    
    #returns number of cells in sudoku
    def length
      if @length
        @length
      else
        @length = size*size
      end
    end
    
    #human representation of a Sudoku
    def to_s
      res  = ""
      zero = ".".center size.to_s.length+1
      size.times do |y|
        res += "\n" if y>0 && y%base == 0
        size.times do |x|
          res += " " if x>0 && x%base == 0
          val = get x, y
          res += val.zero? ? zero : "#{val} "
        end
        res += "\n"
      end
      res
    end
    
    #Store representation of Sudoku
    def to_sutxt version=2
      res = "#{base}:"
      size.times do |y|
        size.times do |x|
          res << " #{get x, y}"
        end
      end
      (version < 2) ? res : res+';'
    end
  end
  
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
  
  #Highly optimized 9x9 Sudoku
  class S3
    include Grid
    
    def size
      SIZE
    end
  end
  
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
  
  #returns best Sudoku implementation for base +n+
  def self.[] n
    n = n.to_i
    case n
    when 3
      S3.new
    when 4..15
      S4_15.new n
    else
      Sn.new n
    end
  end
end
