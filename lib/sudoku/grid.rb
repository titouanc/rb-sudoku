SUDOKU_LIBDIR = File.dirname File.expand_path(__FILE__)

require "#{SUDOKU_LIBDIR}/logic"
require "#{SUDOKU_LIBDIR}/solver"
require "#{SUDOKU_LIBDIR}/generator"

module Sudoku
  #Interface commune des sudokus
  module Grid
    include Logic
    include Generator
    include Solver
  end
end