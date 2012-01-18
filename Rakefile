require 'rubygems'
require 'rake/gempackagetask'
require 'rake/extensiontask'
require 'rake/testtask.rb'
require 'yard'
require './lib/sudoku/version'

spec = Gem::Specification.new do |s|
  s.name          = 'sudokuhandler'
  s.version       = Sudoku::VERSION
  s.platform      = Gem::Platform::RUBY
  s.summary       = "Ruby Sudoku handler"
  s.description   = "Highly optimised Sudoku objects and mixins for Ruby"
  s.author        = "Titouan Christophe"
  s.email         = 'titouanchristophe@gmail.com'
  s.files         = FileList["lib/*.rb", "lib/sudoku/*.rb", "ext/sudoku.c", "Rakefile", "README.md"]
  s.homepage      = 'http://github.com/titouanc/rb-sudoku'
  s.extensions   << 'ext/extconf.rb'
  s.license       = 'Creative Commons BY-NC-SA 3.0'
  s.test_files    = FileList["tests/*"]
  s.rdoc_options += ['--title', 'Sudoku for Ruby', '--main',  'README']
  s.add_development_dependency 'rake-compiler'
  s.add_development_dependency 'yard'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

Rake::ExtensionTask.new(:sudokucore, spec) do |ext|
  ext.ext_dir = 'ext/'
  ext.lib_dir = 'lib/'
end

Rake::TestTask.new do |t|
  t.libs |= ["tests", "lib"]
  t.test_files = FileList['tests/test*.rb']
  t.verbose = true
end

YARD::Rake::YardocTask.new do |t|
  t.files = FileList["lib/sudoku.rb", "lib/sudoku/*.rb"]
  t.options = ['--readme', 'README.md', '--charset', 'UTF-8']
end

desc "Build gem & install"
task :install => FileList["pkg/#{spec.full_name}.gem"] do |t|
  sh "gem install #{t.prerequisites.first}"
end

desc "Uninstall sudoku gem"
task :uninstall do |t|
  sh "gem uninstall #{spec.name}"
end

desc "Push gem to rubygems.org"
task :push => FileList["pkg/#{spec.full_name}.gem"] do |t|
  sh "gem push #{t.prerequisites.first}"
end

desc "Compile et ouvre uen console"
task :console => :compile do |t|
  sh "irb -I ./lib -r sudoku"
end

task :doc => :yard

task :default => [:clobber, :repackage, :compile, :test, :yard]
