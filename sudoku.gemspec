Gem::Specification.new do |s|
  s.name        = 'sudoku'
  s.version     = '0.1.1'
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Ruby Sudoku handler"
  s.description = "Highly optimised Sudoku objects and mixins for Ruby"
  s.author      = "Titouan Christophe"
  s.email       = 'titouanchristophe@gmail.com'
  s.files       = Dir["lib/*", "lib/ext/*"]
  s.homepage    = ''
  s.extensions << 'lib/ext/extconf.rb'
  s.license     = 'Creative Commons BY-NC-SA 3.0'
end