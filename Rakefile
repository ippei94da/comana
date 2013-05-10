# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "comana"
  gem.homepage = "http://github.com/ippei94da/comana"
  gem.license = "MIT"
  gem.summary = %Q{Manager for scientific computing}
  gem.description = %Q{Comana, COmputation MANAger,
    is a software to provide a framework of
    managing scientific computing.
    Researchers on computing have to check calculation and
    generate new calculation and execute, repeatedly.
    The abstract class that this gem provide would help the work.
  }
  gem.email = "ippei94da@gmail.com"
  gem.authors = ["ippei94da"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

#require 'rspec/core'
#require 'rspec/core/rake_task'
#RSpec::Core::RakeTask.new(:spec) do |spec|
#  spec.pattern = FileList['spec/**/*_spec.rb']
#end
#
#RSpec::Core::RakeTask.new(:rcov) do |spec|
#  spec.pattern = 'spec/**/*_spec.rb'
#  spec.rcov = true
#end
#
#task :default => :spec

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

#require 'rcov/rcovtask'
#Rcov::RcovTask.new do |test|
#  test.libs << 'test'
#  test.pattern = 'test/**/test_*.rb'
#  test.verbose = true
#  test.rcov_opts << '--exclude "gems/*"'
#end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "comana #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
