#
# Sudoku handler 
#

require "sudokucore"
require "sudoku/version"
require "sudoku/grid"

module Sudoku 
  #Exception lancée lors d'erreurs de lecture d'une chaine Sutxt
  class MalformedSutxtError < Exception; end
  
  #Exception lancée lors d'operations sur deux sudokus incompatibles
  class NotCompatibleError < Exception; end
  
  #Sudoku 9x9 (base 3) très rapide
  class S3
    include Grid
    private :__initialize
    
    #Argument ignoré, laissé pour des raisons d'uniformité
    def initialize base=3
      __initialize nil
    end
    
    #Renvoie le coté du Sudoku
    # @return (Fixnum)
    def size
      SIZE
    end
  end
  
  #Sudokus de base 4 à 15 rapide
  class S4_15
    include Grid
    private :size_internal
    
    #Renvoie le coté du Sudoku
    # @return (Fixnum)
    def size
      if @size
        @size
      else
        @size = size_internal
      end
    end
  end
  
  #Sudoku générique
  class Sn
    include Grid
    attr_reader :size, :base, :length
    
    def initialize base=3
      @base   = base.to_i
      @size   = @base*@base
      @length = @size*@size
      @grid = Array.new(@size) do |i|
        Array.new(@size){|j| 0}
      end
    end
    
    #Renvoie le coté du Sudoku
    # @return (Fixnum)
    def set x, y, val
      if x<0 || x>=size || y<0 || y>=size || val<0 || val > size
        raise ArgumentError, "#{x},#{y} => #{val} is impossible in a #{size}x#{size} sudoku"
      end
      @grid[x][y] = val
    end
    
    #Renvoie la valeur en x,y
    # @return (Fixnum)
    def get x, y
      if x<0 || x>=size || y<0 || y>=size
        raise ArgumentError, "Is there a #{x},#{y} cell in a #{size}x#{size} sudoku ?"
      end
      @grid[x][y]
    end
    
    #Parcourt tout le sudoku
    # @yield [x, y, val] la position et la valeur courante
    # @return (self)
    def each
      @size.times do |y|
        @size.times do |x|
          yield x, y, @grid[x][y]
        end
      end
      self
    end
  end
  
  ADAPTERS = [
    [3, S3],
    [4..15, S4_15],
    [0, Sn]
  ]
  
  class << self
    #Renvoie la classe de la première implémentation dont la zone comprend n
    # @param [Fixnum] n La base du sudoku
    # @return [Class]
    def [] n
      n = n.to_i
      ADAPTERS.each do |ad|
        zone    = ad[0]
        adapter = ad[1]
        
        return adapter if zone == 0
        
        case n
        when zone 
          return adapter
        end
      end
    end
    
    #Ajoute un adapteur pour la zone definie. 
    # @param [Range, Fixnum] zone La zone de validité de l'adapteur
    # @param [Class] adapter L'adaptateur à ajouter
    def []= zone, adapter
      ADAPTERS.unshift [zone, adapter]
    end
    
    #Renvoie une instance de la meilleure implémentation pour un sudoku de base n
    # @param [Fixnum] n La base du sudoku
    # @return [Grid]
    def best_grid_for n=3
      n = n.to_i
      self[n].new n
    end
    alias :new :best_grid_for
    
    #Renvoie un nouveau Sudoku a partir de la chaine donnee
    # @param [String] str Une chaine Sutxt
    # @return [Grid] Un sudoku rempli avec les données Sutxt
    def parse str
      unless str =~ /(\d+):(.+);/
        raise MalformedSutxtError, "It doesn't seem to be a sutxt line..."
      end

      base = $1.to_i
      return new(base).load(str)
    end
  end
end
