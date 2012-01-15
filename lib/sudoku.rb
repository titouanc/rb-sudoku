module Sudoku
  class MalformedSutxtError < Exception; end
  
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
    def square x, y
      xmin = x/base
      ymin = y/base
      res = []
      
      base.times do |xx|
        base.times do |yy|
          val = get xx+xmin, yy+ymin
          res << val if val != 0
        end
      end
      
      res
    end
    
    def possibilities x, y
      Array.new(size){|i| i+1} - (col(x) | row(y) | square(x,y))
    end
    
    def valid? x, y, val
      val = val.to_i
      return false unless val>0 && val<=size
      return false if col(x).include? val
      return false if row(y).include? val
      return false if square(x, y).include? val
      true
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
    
    def inspect
      "#<#{self.class} #{size}x#{size} #{get 0, 0},#{get 0, 1}, ... , #{get size-2, size-1}, #{get size-1, size-1}>"
    end
    
    #Store representation of Sudoku
    def to_sutxt
      res = "#{base}:"
      size.times do |y|
        size.times do |x|
          res << " #{get x, y}"
        end
      end
      res+';'
    end
  end
end

require 'sudoku/sn'
require 'sudoku/s4_15'
require 'sudoku/s3'

module Sudoku
  class << self
    #returns best Sudoku implementation for base +n+
    def best_grid_for n
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
    
    alias :[] :best_grid_for
  end
  
  def self.parse str
    unless str =~ /(\d+):(.+);/
      raise MalformedSutxtError, "It doesn't seem to be a sutxt line..."
    end
    
    base = $1.to_i
    data = $2.split(/\s+/).delete_if(&:empty?).map(&:to_i)
    unless data.length == base**4
      raise MalformedSutxtError, "Expecting #{base**4} numbers, #{data.length} given"
    end

    res = self.best_grid_for base
    res.each do |x, y, val|
      res.set x, y, data[x+y*res.size]
    end

    return res
  end
end
