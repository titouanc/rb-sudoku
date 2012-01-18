require "sudoku"

class MySudoku < Sudoku::S3
  include Sudoku::Generator
  include Sudoku::Solver
end

if __FILE__ == $0
  s= MySudoku.new
  
  File.open "/Developer/Sudoku/HighOpt/tests/resources/set3.sutxt" do |f|
    f.each do |line|
      s.load line
      
      puts s
      puts "#{s.solve_naive!} ajouts #{'(valide)' if s.valid?} #{'(complet)' if s.complete?}"
      puts s
      puts '-'*25
    end
  end
end
