# sudokuhandler

Le but du projet Sudoku est de fournir des objets optimisés pour la gestion de sudokus, permettant d'essayer différents algorithmes de résolution.
Le Sudoku "classique" (9x9) est optimisé au maximum en temps et en mémoire (41 octets).

## Exemple basique

### Création d'un sudoku de 9x9 en diagonale

    $ irb -r sudoku
  	ruby-1.9.2-p290 :001 > s = Sudoku[3]
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

