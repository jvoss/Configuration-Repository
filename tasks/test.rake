require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  
  test.libs   << 'test'
  test.pattern = ['test/tc_*.rb', 'test/vcs/tc_*']
  test.verbose = true
  
end # Rake::TestTask.new
