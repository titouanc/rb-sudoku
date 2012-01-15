require 'test/unit'
require 'sudoku'

module GridTest
  def create
    klass.new base
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
    s = create
    s.each{|x, y, val| s.set x, x, x+1 if x == y}
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
  end
end

class S3Test < Test::Unit::TestCase
  include GridTest
  def base; 3; end
  def klass; Sudoku::S3; end
  def create; klass.new; end
  
  
end

class S4_15Test < Test::Unit::TestCase
  include GridTest
  def base; 4; end
  def klass; Sudoku::S4_15; end
end

class SnTest < Test::Unit::TestCase
  include GridTest
  def base; 2; end
  def klass; Sudoku::Sn; end
end

class SudokuTest < Test::Unit::TestCase
  def test_autoclass
    [S3Test, S4_15Test, SnTest].each do |g|
      grid = g.new nil
      assert_equal grid.klass, Sudoku[grid.base].class
    end
  end
end
