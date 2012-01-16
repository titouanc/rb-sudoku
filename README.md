# sudokuhandler

Le but du projet Sudoku est de fournir des objets optimisés pour la gestion de sudokus, permettant d'essayer différents algorithmes de résolution.
Le Sudoku "classique" (9x9) est optimisé au maximum en temps et en mémoire (41 octets).

## Exemple basique

### Création d'un sudoku de 9x9 en diagonale

    $ irb -r sudoku
		ruby-1.9.2-p290 :000 > s = Sudoku.new 3
		 => #<Sudoku::S3 9x9 0,0, ... , 0, 0> 
  	ruby-1.9.2-p290 :001 > s = Sudoku[3].new
  	 => #<Sudoku::S3 9x9 0,0, ... , 0, 0> 
  	ruby-1.9.2-p290 :002 > s.each{|x,y,v| s.set x, x, x+1 if x == y}
  	 => #<Sudoku::S3 9x9 1,0, ... , 0, 9> 
  	ruby-1.9.2-p290 :003 > puts s
	
    1 . .  . . .  . . . 
  	. 2 .  . . .  . . . 
  	. . 3  . . .  . . . 
  
  	. . .  4 . .  . . . 
  	. . .  . 5 .  . . . 
  	. . .  . . 6  . . . 
  
  	. . .  . . .  7 . . 
  	. . .  . . .  . 8 . 
  	. . .  . . .  . . 9 
  	 => nil 

###Exportation du sudoku

    ruby-1.9.2-p290 :004 > s.to_sutxt
     => "3: 1 0 0 0 0 0 0 0 0 0 2 0 0 0 0 0 0 0 0 0 3 0 0 0 0 0 0 0 0 0 4 0 0 0 0 0 0 0 0 0 5 0 0 0 0 0 0 0 0 0 6 0 0 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 0 0 8 0 0 0 0 0 0 0 0 0 9;" 
    ruby-1.9.2-p290 :005 > s2 = Sudoku.parse s.to_sutxt
     => #<Sudoku::S3 9x9 1,0, ... , 0, 9> 

### Un peu de logique

    ruby-1.9.2-p290 :006 > s.possibilities 0, 1
     => [4, 5, 6, 7, 8, 9] 
    ruby-1.9.2-p290 :007 > s.valid? 1, 0, 3
     => false 
    ruby-1.9.2-p290 :008 > s.valid? 1, 0, 5
     => true 
		ruby-1.9.2-p290 :009 > s.col 2
		 => [3] 
		ruby-1.9.2-p290 :010 > s.row 3
		 => [4] 
		ruby-1.9.2-p290 :011 > s.square 3,3
		 => [4, 5, 6]

### Generateur
		
		class MySudoku < Sudoku::S4_15
			include Sudoku::Generator
		end
		
		s = MySudoku.new 5
		s.make_valid
		puts s
		
		=begin     =>>
		1  2  3  4  5   6  7  8  9  10  11 12 13 14 15  16 17 18 19 20  21 22 23 24 25 
		6  7  8  9  10  11 12 13 14 15  16 17 18 19 20  21 22 23 24 25  1  2  3  4  5  
		11 12 13 14 15  16 17 18 19 20  21 22 23 24 25  1  2  3  4  5   6  7  8  9  10 
		16 17 18 19 20  21 22 23 24 25  1  2  3  4  5   6  7  8  9  10  11 12 13 14 15 
		21 22 23 24 25  1  2  3  4  5   6  7  8  9  10  11 12 13 14 15  16 17 18 19 20 

		2  3  4  5  6   7  8  9  10 11  12 13 14 15 16  17 18 19 20 21  22 23 24 25 1  
		7  8  9  10 11  12 13 14 15 16  17 18 19 20 21  22 23 24 25 1   2  3  4  5  6  
		12 13 14 15 16  17 18 19 20 21  22 23 24 25 1   2  3  4  5  6   7  8  9  10 11 
		17 18 19 20 21  22 23 24 25 1   2  3  4  5  6   7  8  9  10 11  12 13 14 15 16 
		22 23 24 25 1   2  3  4  5  6   7  8  9  10 11  12 13 14 15 16  17 18 19 20 21 

		3  4  5  6  7   8  9  10 11 12  13 14 15 16 17  18 19 20 21 22  23 24 25 1  2  
		8  9  10 11 12  13 14 15 16 17  18 19 20 21 22  23 24 25 1  2   3  4  5  6  7  
		13 14 15 16 17  18 19 20 21 22  23 24 25 1  2   3  4  5  6  7   8  9  10 11 12 
		18 19 20 21 22  23 24 25 1  2   3  4  5  6  7   8  9  10 11 12  13 14 15 16 17 
		23 24 25 1  2   3  4  5  6  7   8  9  10 11 12  13 14 15 16 17  18 19 20 21 22 

		4  5  6  7  8   9  10 11 12 13  14 15 16 17 18  19 20 21 22 23  24 25 1  2  3  
		9  10 11 12 13  14 15 16 17 18  19 20 21 22 23  24 25 1  2  3   4  5  6  7  8  
		14 15 16 17 18  19 20 21 22 23  24 25 1  2  3   4  5  6  7  8   9  10 11 12 13 
		19 20 21 22 23  24 25 1  2  3   4  5  6  7  8   9  10 11 12 13  14 15 16 17 18 
		24 25 1  2  3   4  5  6  7  8   9  10 11 12 13  14 15 16 17 18  19 20 21 22 23 

		5  6  7  8  9   10 11 12 13 14  15 16 17 18 19  20 21 22 23 24  25 1  2  3  4  
		10 11 12 13 14  15 16 17 18 19  20 21 22 23 24  25 1  2  3  4   5  6  7  8  9  
		15 16 17 18 19  20 21 22 23 24  25 1  2  3  4   5  6  7  8  9   10 11 12 13 14 
		20 21 22 23 24  25 1  2  3  4   5  6  7  8  9   10 11 12 13 14  15 16 17 18 19 
		25 1  2  3  4   5  6  7  8  9   10 11 12 13 14  15 16 17 18 19  20 21 22 23 24
		=end
		
		s.valid? 		   # => true
		s.complete? 	 # => true
		s.completable? # => true
		
### Utiliser son propre adapteur

#### Un adapteur doit au moins définir les méthodes suivantes:

* get(x, y)
* set(x, y, val)
* each(){|x, y, val| ... }
* size()
* initialize(base)
* initialize_copy(parent) (automatique si on n'utilise que des objets ruby)

#### Exemple:

NB: cet exemple ne tient pas compte de la gestion des erreurs
		
		class MonSuperAdapteur
			attr_reader :size
			
			include Sudoku::Generator #methodes de generation automatique
			include Sudoku::Grid      #methodes communes a tous les sudokus
			
			def initialize base
				@size = base*base
				@data = Array.new(@size*@size){0}
			end
			
			def get x, y
				@data[x+y*size]
			end
			
			def set x, y, val
				@data[x+y*size] = val
			end
			
			def each
				@data.each_with_index do |val, i|
					yield i%size, i/size, val
				end
				self
			end
		end
		
		Sudoku[4..7] = MonSuperAdapteur #Tous les sudokus de base 4 à 7 créés automatiquement
																		#seront des MonSuperAdapteur
		Sudoku.new(3).class	# => Sudoku::S3
		Sudoku.new(4).class	# => MonSuperAdapteur					
		
		Sudoku[0]    = MonSuperAdapteur #Tous les sudokus, par defaut
		
		Sudoku.new(3).class # => MonSuperAdapteur