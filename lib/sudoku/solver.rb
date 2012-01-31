module Sudoku
  #Methodes de resolution des sudokus
  module Solver
    #Renvoie les nombres manquants dans le carré comprenant la case x,y
    # @param [Fixnum] x La colonne d'une case du carré à traiter
    # @param [Fixnum] y La rangée d'une case du carré à traiter
    # @return [Array] Les nombres manquants
    def missing_square x, y
      Array.new(size){|i| i+1} - square(x,y)
    end
    
    #Renvoie les nombres manquants dans la colonne
    # @param [Fixnum] x La colonne à traiter
    # @return [Array] Les nombres manquants
    def missing_col x
      Array.new(size){|i| i+1} - col(x)
    end
    
    #Renvoie les nombres manquants dans la colonne
    # @param [Fixnum] y La ligne à traiter
    # @return [Array] Les nombres manquants
    def missing_row y
      Array.new(size){|i| i+1} - row(y)
    end
    
    #Ajoute un nombre chaque fois que c'est la seule possibilité
    # @return [Fixnum] le nombre de nombres ajoutés dans la grille
    def solve_uniq_possibilities!
      res = 0
      loop do
        adds = 0
        each do |x, y, val|
          next unless val.zero?
          
          p = possibilities x, y
          if p.length == 1
            set x, y, p.first
            adds += 1
          end
          
        end
        break if adds == 0
        res += adds
      end
      res
    end
    
    #Ajoute un nombre chaque fois que c'est la seule position possible dans la colonne
    # @param [Fixnum] x La colonne à traiter
    # @return [Fixnum] le nombre de nombres ajoutés
    def solve_col! x
      adds = 0
      
      missing_col(x).each do |val|
        pos = []
        size.times do |y|
          next unless get(x,y) == 0
          pos << [x,y] if valid? x, y, val
        end
        if pos.length == 1
          set pos[0][0], pos[0][1], val
          adds += 1
        end
      end
      
      adds
    end
    
    #Ajoute un nombre chaque fois que c'est la seule position possible dans la ligne
    # @param [Fixnum] y La ligne à traiter
    # @return [Fixnum] le nombre de nombres ajoutés
    def solve_row! y
      adds = 0
      
      missing_row(y).each do |val|
        pos = []
        size.times do |x|
          next unless get(x,y) == 0
          pos << [x,y] if valid? x, y, val
        end
        if pos.length == 1
          set pos[0][0], pos[0][1], val
          adds += 1
        end
      end
      
      adds
    end
    
    #Ajoute un nombre chaque fois que c'est la seule position possible dans le carré
    # @param [Fixnum] x La colonne d'une case du carré à traiter
    # @param [Fixnum] y La rangée d'une case du carré à traiter
    # @return [Fixnum] le nombre de nombres ajoutés
    def solve_square! xx, yy
      xmin = xx - (xx%base)
      ymin = yy - (yy%base)
      adds = 0
      
      missing_square(xx, yy).each do |val|
        pos = []
        base.times do |i|
          base.times do |j|
            x = xmin + i
            y = ymin + j
            next unless get(x,y) == 0
            pos << [x,y] if valid? x, y, val
          end
        end
        if pos.length == 1
          set pos[0][0], pos[0][1], val
          adds += 1
        end
      end
      
      adds
    end
    
    #Utilise solve_uniq_possibilities!, solve_col!, solve_row! et solve_square!
    #tant qu'ils ajoutent des nombres
    # @return [Fixnum] le nombre de nombres ajoutés
    def solve_naive!
      res = 0
      
      loop do
        adds = solve_uniq_possibilities!
        size.times do |i|
          adds += solve_col! i
          adds += solve_row! i
          
          x = (i*base) % size
          y = (i/base) * base
          adds += solve_square! x, y
        end
        break if adds.zero?
        res += adds
      end
      
      res
    end
    
    # Resoud le sudoku par backtracking
    # @return [Fixnum] le nombre de nombres ajoutés dans la grille
    def solve_backtrack!
      res = solve_naive!
            
      each do |x, y, cur_val|
        next unless cur_val.zero?
        p = possibilities x, y
        p.each do |val|
          copy = clone
          copy.set x, y, val
          adds = copy.solve_backtrack!
          if copy.complete?
            self.import copy
            return res+adds+1
          end
        end
      end
      
      res
    end
    
    # Renvoie un nouveau sudoku reolu par backtracking
    # Si le temps de solution depasse timeout, le solveur est arrete
    # @param [Fixnum] timeout Le temps maximum en secondes
    # @return [Sudoku::Grid] Le sudoku resolu, ou en partie resolu si le timeout a joue
    def solve_backtrack_timeout timeout
      res = self.clone
      Thread.new(res){|s| s.solve_backtrack!}.join(timeout)
      res
    end
    
    #Enleve les nombres qui sont impossibles de la grille
    # @return (Fixnum) le nombre de nombres enlevés
    def remove_impossible!
      removes = 0
      each do |x, y, val|
        unless valid_cell? x, y, val
          set x, y, 0 
          removes += 1
        end
      end
      removes
    end
  end
end