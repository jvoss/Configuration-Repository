# Copyright 2010 Andrew R. Greenwood and Jonathan P. Voss
#
# This file is part of Configuration Repository (CR)
#
# Configuration Repository (CR) is free software: you can redistribute 
# it and/or modify it under the terms of the GNU General Public License 
# as published by the Free Software Foundation, either version 3 of the 
# License, or (at your option) any later version.
#
# Configuration Repository (CR) is distributed in the hope that it will 
# be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
#

require 'rake'
require 'rake/clean'

CLOBBER.include('coverage', 'pkg', 'reports', 'tmp')

desc "Open an irb session preloaded with this library"
task :console do
  
  sh "irb -rubygems -I lib -r lib/cr.rb"

end # task :console

# Jeweler Tasks
begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name          = "CR"
    s.summary       = "Archive network device configuration into version control"
    s.email         = "jvoss@onvox.net"
    s.homepage      = "http://github.com/jvoss/Configuration-Repository"
    s.description   = "Simplify managing device configuration backups in version control"
    s.authors       = ["Andrew R. Greenwood", "Jonathan P. Voss"]
    s.files         =  FileList["[A-Z]*", "{lib,test}/**/*", '.gitignore']
    s.add_dependency 'dnsruby'
    s.add_dependency 'git'
    s.add_dependency 'net-scp'
    s.add_dependency 'net-ssh', '>= 2.0.23'
    s.add_dependency 'rake'
    s.add_dependency 'saikuro_treemap'
    s.add_dependency 'shoulda'
    s.add_dependency 'snmp'
  end

rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end # begin

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = "ConfigurationRepository"
  rdoc.main     = 'README.rdoc'
  rdoc.rdoc_files.include('*.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  
end # Rake::RDocTask.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  
  test.libs   << 'test'
  test.pattern = ['test/tc_*.rb', 'test/vcs/tc_*']
  test.verbose = true
  
end # Rake::TestTask.new

namespace :test do
  desc 'Measures test coverage'
  task :coverage do
    rm_f "coverage"
    rcov = "rcov -Ilib --exclude /gems/,/Library/,/usr/,spec --html"
    system("#{rcov} test/tc_*.rb test/vcs/tc_*.rb")
  end # task :coverage
end # namespace :test

desc "Look for TODO and FIXME tags in the code"
task :todo do
  
  def egrep(pattern)
    
    Dir['**/*.rb'].each do |filename|
      
      # ignore todo/fixme comments in this file
      next if filename == 'Rakefile.rb' 
      
      count = 0
      
      open(filename) do |file|
        
        while line = file.gets
          
          count += 1
          
          if line =~ pattern
            puts "#{filename}:#{count}:#{line}"
          end # if
          
        end # while
        
      end # open
      
    end # Dir
    
  end # def egrep
  
  egrep /(FIXME|TODO|TBD)/
  
end # task :todo

require 'saikuro_treemap'
namespace :metrics do
  desc 'Generate CCN treemap'
  task :ccn_treemap do
    SaikuroTreemap.generate_treemap :code_dirs => ['lib']
  end # task :ccn_treemap
end # namespace :metrics 
