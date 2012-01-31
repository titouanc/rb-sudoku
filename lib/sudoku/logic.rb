module Sudoku
  #Logique de base du Sudoku
  module Logic
    #Renvoie le contenu de la ligne x
    # @return (Array)
    def col x
      res = []
      size.times do |y|
        val = get x, y
        res << val if val != 0
      end
      res
    end
    
    #Renvoie le contenu de la ligne y
    # @return (Array)
    def row y 
      res = []
      size.times do |x|
        val = get x, y
        res << val if val != 0
      end
      res
    end
    
    #Renvoie le contenu du carré contenant la case x,y
    # @return (Array)
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
    # @return (Array)
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
      return true if val.zero?
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
    
    # @overload valid?(x, y, val)
    #   Vérifie si val est valide en x,y
    #   @param [Fixnum] x   La colonne de la valeur à vérifier
    #   @param [Fixnum] y   La ligne de la valeur à vérifier
    #   @param [Fixnum] val La valeur à vérifier
    #   @return [Boolean] true si la valeur est valide, false sinon
    # @overload valid?
    #   Vérifie que toutes les valeurs du Sudoku sont vlaides
    #   @return [Boolean] true si toutes les valeurs sont valides, false sinon
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
    # @return (Fixnum)
    def base
      if @base
        @base
      else
        @base = (size**0.5).to_i
      end
    end
    
    #Renvoie le nombre de cases dans le sudoku
    # @return (Fixnum)
    def length
      if @length
        @length
      else
        @length = size*size
      end
    end
    
    # Compte le nombre d'occurences pour les valeurs
    # @return [Hash] L'association valeur => occurences
    # @overload count(*values)
    #   Compte les occurences pour les valeurs passées en paramètres
    #   @param [*Fixnum] values Les valeurs à compter
    # @overload count
    #   Compte les occurences de chaque valeur
    def count *values
      values = Array.new(size){|i| i+1} if values.empty?
      
      res = {}
      values.each do |val| 
        if val<0 || val>size
          raise ArgumentError, "Impossible value #{val} in a #{size}x#{size} sudoku"
        end
        res[val] = 0
      end
      
      each do |x, y, val|
        res[val] += 1 if values.include? val
      end
      
      res
    end
    
    #Représentation texte humainement lisible
    # @return (String)
    def to_s
      res  = ""
      width = size.to_s.length
      zero = ".".center width+1
      
      size.times do |y|
        res += "\n" if y>0 && y%base == 0
        size.times do |x|
          res += " " if x>0 && x%base == 0
          val = get x, y
          res += val.zero? ? zero : "#{val.to_s.center width} "
        end
        res += "\n"
      end
      res
    end
    
    #Représentation courte (utile dans irb)
    # @return [String]
    def inspect
      "#<#{self.class} #{size}x#{size} [#{get 0, 0}, #{get 0, 1}, ... , #{get size-2, size-1}, #{get size-1, size-1}]>"
    end
    
    #Représentation pour l'enregistrement
    # @return (String)
    def to_sutxt
      res = "#{base}:"
      size.times do |y|
        size.times do |x|
          res << " #{get x, y}"
        end
      end
      res+';'
    end
    
    #Charge un Sudoku depuis une chaine Sutxt
    # @return (self)
    # @raise [MalformedSutxtError] Chaine Sutxt mal formatee
    # @raise [NotCompatibleError]  La chaine Sutxt correspond a un Sudoku de base differente
    def load sutxt_str
      unless sutxt_str =~ /(\d+):(.+);/
        raise MalformedSutxtError, "It doesn't seem to be a sutxt line..."
      end

      sutxt_base = $1.to_i
      unless sutxt_base == base
        raise NotCompatibleError, "A #{base} sudoku cannot load a #{sutxt_base} Sutxt"
      end
      
      data = $2.split(/\s+/).delete_if(&:empty?).map(&:to_i)
      unless data.length == length
        raise MalformedSutxtError, "Expecting #{length} numbers, #{data.length} given"
      end
      
      size.times do |y|
        size.times do |x|
          set x, y, data.shift
        end
      end
      self
    end
    
    #Charge un sudoku depuis un autre sudoku
    # @param [Grid] l'autre Sudoku
    # @return (self)
    # @raise [NotCompatibleError] L'autre sudoku est de base differente
    def import other
      unless size == other.size
        raise NotCompatibleError, "Cannot import a #{other.base} sudoku in a #{base} sudoku"
      end
      other.each{|x,y,v| set x, y, v}
      self
    end
  end
end