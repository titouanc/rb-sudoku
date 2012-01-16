#
# Sudoku handler 
#

require "sudokucore"
require "sudoku/version"

module Sudoku 
  #Exception lancée lors d'erreurs de lecture d'une chaine Sutxt
  class MalformedSutxtError < Exception; end
  
  #Permet de generer rapidement un sudoku
  module Generator
    #Remplit la diagonale descendante de 1 a self.size
    def make_diagonal
      each{|x,y,val| set x,x,x+1 if x==y}
      self
    end
    
    #Remplit tout le sudoku de maniere a ce qu'il soit valide
    def make_valid
      pattern = Array.new(size){|i| i+1}
      size.times do |y|
        size.times do |x|
          set x, y, pattern[x]
        end
        base.times{|i| pattern.push pattern.shift}
        pattern.push pattern.shift if base - (y%base) == 1
      end
      self
    end
  end
  
  #Taches communes a tous les Sudokus
  module Grid
    #Renvoie le contenu de la ligne x
    def col x
      res = []
      size.times do |y|
        val = get x, y
        res << val if val != 0
      end
      res
    end
    
    #Renvoie le contenu de la ligne y
    def row y 
      res = []
      size.times do |x|
        val = get x, y
        res << val if val != 0
      end
      res
    end
    
    #Renvoie le contenu du carré contenant la case x,y
    def square x, y
      xmin = x - (x%base)
      ymin = y - (y%base)
      res = []
      
      base.times do |xx|
        base.times do |yy|
          val = get xx+xmin, yy+ymin
          res << val if val != 0
        end
      end
      
      res
    end
    
    #Renvoie true si le sudoku ne contient aucune case vide
    def complete?
      each{|x,y,val| return false if val == 0}
      true
    end
    
    #Renvoie true si chaque case a au moins 1 possibilité à ce stade
    def completable?
      completed = 0
      each do |x, y, val|
        return false if possibilities(x, y).empty?
      end
      return true
    end
    
    #Renvoie toutes les possibilités pour la case x,y
    def possibilities x, y
      res = Array.new(size){|i| i+1}
      xmin = x-x%base
      ymin = y-y%base
      
      size.times do |i|
        res.delete get(x,i) if i!=y
        res.delete get(i,y) if i!=x
        xx, yy = xmin+i%base, ymin+i/base
        res.delete get(xx, yy) if xx!=x && yy!=y
      end
      
      res
    end
    
    #Renvoie true si tous les nombres de la grille sont valides
    def valid_grid?
      each do |x, y, val|
        next if val.zero?
        return false unless valid_cell? x, y, val
      end
      
      true
    end
    
    #Renvoie true si val est possible en x,y
    def valid_cell? x, y, val
      val  = val.to_i
      xmin = x-x%base
      ymin = y-y%base
      
      size.times do |i|
        return false if i!=y && get(x,i)==val
        return false if i!=x && get(i,y)==val
        xx, yy = xmin+i%base, ymin+i/base
        return false if xx!=x && yy!=y && get(xx, yy) == val
      end
      
      true
    end
    
    #Si aucun argument n'est passé => valid_grid?
    #Si 3 arguments sont passés    => valid_cell? x, y, val
    def valid? *args
      if args.empty?
        valid_grid?
      elsif args.length == 3
        valid_cell? *args
      else
        raise ArgumentError, "wrong number of arguments(#{args.length} for 0 or 3)"
      end
    end
    
    #Renvoie la base du sudoku
    def base
      if @base
        @base
      else
        @base = (size**0.5).to_i
      end
    end
    
    #Renvoie le nombre de cases dans le sudoku
    def length
      if @length
        @length
      else
        @length = size*size
      end
    end
    
    #Représentation texte humainement lisible
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
    
    #Représentation courte (utile dans irb)
    def inspect
      "#<#{self.class} #{size}x#{size} [#{get 0, 0}, #{get 0, 1}, ... , #{get size-2, size-1}, #{get size-1, size-1}]>"
    end
    
    #Représentation pour l'enregistrement
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
  
  #Sudoku 9x9 (base 3) très rapide
  class S3
    include Grid
    private :__initialize
    
    #Argument ignoré, laissé pour des raisons d'uniformité
    def initialize base=3
      __initialize nil
    end
    
    def size
      SIZE
    end
  end
  
  #Sudokus de base 4 à 15 rapide
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
    
    def set x, y, val
      if x<0 || x>=size || y<0 || y>=size || val<0 || val > size
        raise ArgumentError, "#{x},#{y} => #{val} is impossible in a #{size}x#{size} sudoku"
      end
      @grid[x][y] = val
    end
    
    def get x, y
      if x<0 || x>=size || y<0 || y>=size
        raise ArgumentError, "Is there a #{x},#{y} cell in a #{size}x#{size} sudoku ?"
      end
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
  
  class << self
    #Renvoie la classe de la meilleure implémentation pour un sudoku de base n
    def [] n
      n = n.to_i
      case n
      when 3
        S3
      when 4..15
        S4_15
      else
        Sn
      end
    end
    
    #Renvoie une instance de la meilleure implémentation pour un sudoku de base n
    def best_grid_for n
      n = n.to_i
      self[n].new n
    end
    alias :new :best_grid_for
    
    #Renvoie un nouveau Sudoku a partir de la chaine donnee
    def parse str
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
end
