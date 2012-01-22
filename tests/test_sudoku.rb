require 'test/unit'
require 'sudoku'

class MyTestCase < Test::Unit::TestCase
  #Certains Rubys n'ont pas refute...
  def refute what, *args
    begin
      return super(what, *args)
    rescue NoMethodError => e
      return assert(!what, args)
    end
  end
  
  def test_myrefute
    refute false, "Implementation refute"
  end
end

module GridTest
  def create
    klass.new base
  end
  
  def test_initialize
    s = create
    s.each{|x,y,val| assert_equal 0, val, "Sudoku initialise a 0 partout"}
  end
  
  def test_diagonal
    s = create.make_diagonal
    (s.size-1).times{|i| assert_equal 1, s.get(i+1, i+1)-s.get(i, i)}
  end
  
  def test_limits
    s = create
    assert_raise(ArgumentError){s.get s.size, 1}
    assert_raise(ArgumentError){s.get 1, s.size}
    assert_raise(ArgumentError){s.set s.size, 1, 1}
    assert_raise(ArgumentError){s.set 1, s.size, 1}
    assert_raise(ArgumentError){s.set 1, 1, s.size+1}
  end
  
  def test_getset
    s = create
    s.set 0, 0, 1
    assert_equal 1, s.get(0, 0)
  end
  
  def test_clone
    s1 = create
    s1.each{|x,y,v| s1.set x, y, rand(s1.size)+1}
      
    s2 = s1.clone
    s2.each do |x, y, v|
      assert_equal s1.get(x,y), v, "Clonage cellule #{x},#{y}"
    end
  end
  
  def test_each
    s = create.make_diagonal
    s.size.times{|x| assert_equal x+1, s.get(x, x)}
  end
  
  def test_size
    s = create
    assert_equal base   , s.base
    assert_equal base**2, s.size
    assert_equal base**4, s.length
  end

  def test_col_row_square
    s = create
    2.times do |x|
      2.times do |y|
        s.set x, y, x+y*2+1
      end
    end
    assert_equal [1, 2, 3, 4], s.square(0, 0).sort
    assert_equal [1, 2],       s.row(0).sort
    assert_equal [1, 3],       s.col(0).sort
  end

  def test_possibilities
    s = create
    s.set 1,0,1
    s.set 0,1,2
    
    assert s.possibilities(1, 1).include?(3)
    refute s.possibilities(1, 1).include?(1)
    refute s.valid?(1,1,1), "Case non occupee, valeur impossible"
    refute s.valid?(0,1,1), "Case deja occupee, valeur impossible"
    assert s.valid?(1,1,4), "Case non occupee, valeur plausible"
    assert s.valid?(1,1,0), "0 est toujours valide"
    assert s.valid?(1,0,1), "Case deja occupee, valeur plausible"
    
    s.possibilities(1, 1).each do |p|
      assert s.valid?(1, 1, p), "Possibilite #{p} doit etre valide"
    end
  end

  def test_sutxt
    sutxt = "#{base}:"
    size = base*base
    size.times do |y|
      size.times {|x| sutxt += " #{x+1}"}
    end
    sutxt += ';'
    
    s = Sudoku.parse(sutxt)
    assert_equal sutxt, s.to_sutxt
    assert_equal 1, s.get(0,0)
    assert_equal 1, s.get(0,1)
    assert_equal 2, s.get(1,0)
  end

  def test_complete
    s = create
    refute s.complete?
    assert s.completable?
    assert s.valid?
    
    s.each{|x,y,val| s.set x, y, 1}
    assert s.complete?
    assert s.completable?
    refute s.valid?
  end

  def test_count
    s = create    
    assert_equal s.length, s.count(0)[0], "Comptage de 0 dans un sudoku vide"
    
    s.make_diagonal
    expected = {}
    s.size.times{|x| expected[x+1] = 1}
    assert_equal expected, s.count, "Comptage de valeurs dans un sudoku diagonal"
    
    assert_raise(ArgumentError, "Comptage de valeur > size impossible"){s.count(s.size+1)}
  end

  def test_import
    s  = create.make_valid
    s2 = Sudoku::Sn.new(s.size)
    s2.each do |x,y,v|
      assert_equal s.get(x,y), v, "Importation d'une grille vers grille generique, cellules egales"
    end
    
    s3 = Sudoku::Sn.new(s.size+1)
    assert_raise(Sudoku::NotCompatibleError, "Importation d'une grille vers grille de taille differente"){s3.import s}
  end
end

module GeneratorTest
  def test_generator_diagonal
    s = create.make_diagonal
    s.size.times{|x| assert_equal x+1, s.get(x, x)}
  end
  
  def test_generator_valid
    s = create.make_valid
    assert s.valid?
    assert s.completable?
    assert s.complete?
  end
end

module SolverTest
  SOLVER_TIMEOUT = 10 #sec
  
  def test_missing
    s = create
    s.set 0,1,1
    s.set 1,0,2
    
    assert s.missing_square(0,0).include?(3)
    refute s.missing_square(0,0).include?(1)
    
    assert s.missing_col(0).include?(2)
    refute s.missing_col(0).include?(1)
    
    assert s.missing_row(0).include?(1)
    refute s.missing_row(0).include?(2)
  end

  def test_solve_uniq
    s = create.make_valid
    s.set 0,0,0
    s.set 1,1,0
    
    assert_equal 2, s.solve_uniq_possibilities!, "Solution par possibilites uniques d'un sudoku complet-2cases"
    assert s.complete?
  end

  def test_solve_backtrack
    s = create.make_valid_incomplete
    t = Thread.new(s){|sudoku| sudoku.solve_backtrack!}
    t.join SOLVER_TIMEOUT
    assert s.complete?, "Toujours une solution en backtracking en max. #{SOLVER_TIMEOUT}s"
  end
end

module SudokuTest
  include GridTest
  include SolverTest
  include GeneratorTest
end

class S3Test < MyTestCase
  include SudokuTest
  
  def base; 3; end
  def klass; Sudoku::S3; end
  
  def test_square
    s = create.make_diagonal
    9.times do |i|
      assert_equal [1+3*(i/3), 2+3*(i/3), 3+3*(i/3)], s.square(i,i)
    end
  end

  def test_possibilities
    super
    s = create.make_diagonal
    assert_equal [1, 4, 5, 6, 7, 8, 9], s.possibilities(0, 0).sort
  end

  #Tests pour l'implementation en C de valid_cell?
  def test_valid_cimpl
    s = klass.new
    s.set 0, 7, 1
    s.set 7, 0, 2
    s.set 1, 1, 3
    
    refute s.valid?(0, 0, 1), "Colonne"
    refute s.valid?(0, 0, 2), "Ligne"
    refute s.valid?(0, 0, 3), "Carre"
    assert s.valid?(0, 0, 4)
    
    assert_raise(ArgumentError){s.valid?(9, 2, 3)}
  end
end

class S4_15Test < MyTestCase
  include SudokuTest
  
  def base; 4; end
  def klass; Sudoku::S4_15; end
  
  def test_toolarge
    assert_raise(ArgumentError){klass.new 16}
  end
end

class SnTest < MyTestCase
  include SudokuTest
  
  def base; 2; end
  def klass; Sudoku::Sn; end
end

class GlobalTest < Test::Unit::TestCase
  def test_autoclass
    {Sudoku::S3 => 3, Sudoku::S4_15 => 4, Sudoku::Sn => 2}.each do |klass, base|
      assert_equal klass, Sudoku[base], "Sudoku[#{base}] => #{klass}"
    end
    
    Sudoku[2..7] = GridTest
    assert_equal GridTest, Sudoku[6], "Definition d'autoclasses persos"
  end
  
  def test_speed
    t = [Time.now]
    klasses = [Sudoku::S3, Sudoku::S4_15, Sudoku::Sn]
    
    klasses.each do |k|    
      s = k.new 3
      1000.times{|i| s.each{|x,y,v| s.valid? x,y,9}}
      t << Time.now
    end
    
    2.times do |i|
      assert (t[i+1] - t[i])<(t[i+2] - t[i+1]), "#{klasses[i]} plus rapide que #{klasses[i+1]}"
    end
  end
end

