require 'rubygems'
require 'rake'
require 'rake/clean'
require 'lib/core'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  
  test.libs   << 'test'
  test.pattern = 'test/tc_*.rb'
  test.verbose = true
  
end # Rake::TestTask.new

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = "ConfigurationRepository #{CR::VERSION}"
  rdoc.rdoc_files.include('*.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  
end # Rake::RDocTask.new

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

desc "Open an irb session preloaded with this library"
task :console do
  
  sh "irb -rubygems -I lib -r core.rb"

end # task :console
