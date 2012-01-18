module Sudoku
  #Permet de generer rapidement un sudoku
  module Generator
    #Remplit la diagonale descendante de 1 a self.size
    # @return (self)
    def make_diagonal
      each{|x,y,val| set x,x,x+1 if x==y}
      self
    end
    
    #Remplit tout le sudoku de maniere a ce qu'il soit valide
    # @return (self)
    def make_valid
      pattern = Array.new(size){|i| i+1}.shuffle
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
end