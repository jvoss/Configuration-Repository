require 'rake/rdoctask'

Rake::RDocTask.new do |rdoc|
  
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'ConfigurationRepository'
  rdoc.main     = 'README.rdoc'
  rdoc.rdoc_files.include('*.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  
end # Rake::RDocTask.new
