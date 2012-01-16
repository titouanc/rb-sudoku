require 'test/unit'
require 'sudoku'

module GridTest
  def create
    klass.new base
  end
  
  def diagonal
    s = create
    s.each{|x, y, val| s.set x,x,x+1 if x==y}
    s
  end
  
  def test_diagonal
    s = diagonal
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
    s1.set 0, 0, 1
      
    s2 = s1.clone
      
    assert_equal 1, s2.get(0, 0)
  end
  
  def test_each
    s = diagonal
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
    s.set 0,0,1
    s.set 0,1,2
    
    assert s.possibilities(1, 1).include?(3)
    assert s.possibilities(1, 1).include?(4)
    
    assert s.valid?(1,1,3)
    assert s.valid?(1,1,4)
    
    refute s.valid?(1,1,0)
    refute s.valid?(1,1,1)
    assert s.valid?(0,0,1)
  end

  def test_sutxt
    sutxt = "#{base}:"
    size = base*base
    size.times do |y|
      size.times {|x| sutxt << " #{x+1}"}
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
end

module GeneratorTest
  def generator
    Class.new klass do
      include Sudoku::Generator
    end
  end
  
  def test_diagonal
    s = generator.new(base).make_diagonal
    s.size.times{|x| assert_equal x+1, s.get(x, x)}
  end
  
  def test_valid
    s = generator.new(base).make_valid
    assert s.valid?
    assert s.completable?
    assert s.complete?
  end
end

class S3Test < Test::Unit::TestCase
  include GridTest
  include GeneratorTest
  
  def base; 3; end
  def klass; Sudoku::S3; end
  def create; klass.new; end
  
  def test_square
    s = diagonal
    9.times do |i|
      assert_equal [1+3*(i/3), 2+3*(i/3), 3+3*(i/3)], s.square(i,i)
    end
  end

  def test_possibilities
    super
    s = diagonal
    assert_equal [1, 4, 5, 6, 7, 8, 9], s.possibilities(0, 0).sort
  end
end

class S4_15Test < Test::Unit::TestCase
  include GridTest
  include GeneratorTest
  
  def base; 4; end
  def klass; Sudoku::S4_15; end
  
  def test_toolarge
    assert_raise(ArgumentError){klass.new 16}
  end
end

class SnTest < Test::Unit::TestCase
  include GridTest
  include GeneratorTest
  
  def base; 2; end
  def klass; Sudoku::Sn; end
end

class SudokuTest < Test::Unit::TestCase
  def test_autoclass
    [S3Test, S4_15Test, SnTest].each do |g|
      grid = g.new nil
      assert_equal grid.klass, Sudoku[grid.base]
    end
  end
end

