require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "ikran"
    gem.summary = %Q{Simple HTTP console testing framework}
    gem.description = %Q{Simple console application for testing HTTP server}
    gem.email = "darthdeus@gmail.com"
    gem.homepage = "http://github.com/darthdeus/ikran"
    gem.authors = ["darthdeus"]
    gem.add_dependency "addressable", ">= 2.1.1"
    gem.add_development_dependency "rspec", ">= 2.0.0"
    gem.add_development_dependency "cucumber", ">= 0.9.4"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:core) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['--backtrace']
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ikran #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
