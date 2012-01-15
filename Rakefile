require 'rubygems'
require 'rake/gempackagetask'
require 'rake/extensiontask'
require 'rake/testtask.rb'

spec = Gem::Specification.new do |s|
  s.name        = 'sudoku'
  s.version     = '0.1.1'
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Ruby Sudoku handler"
  s.description = "Highly optimised Sudoku objects and mixins for Ruby"
  s.author      = "Titouan Christophe"
  s.email       = 'titouanchristophe@gmail.com'
  s.files       = FileList["lib/*.rb", "ext/*", "Rakefile", "README.md"]
  s.homepage    = 'http://github.com/titouanc/rb-sudoku'
  s.extensions << 'ext/extconf.rb'
  s.license     = 'Creative Commons BY-NC-SA 3.0'
  s.test_files  = FileList["tests/*"]
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

Rake::ExtensionTask.new(:sudokucore, spec) do |ext|
  ext.ext_dir = 'ext/'
end

Rake::TestTask.new do |t|
  t.libs << "tests"
  t.test_files = FileList['tests/test*.rb']
  t.verbose = true
end

desc "Install with bundled gem"
task :install => FileList['pkg/sudoku'] do |t|
  
end

task :default => [:repackage, :compile, :test]
