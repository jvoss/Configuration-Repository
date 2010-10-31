namespace :test do

  desc 'Measures test coverage'
  task :coverage do

    rm_f 'coverage'

    rcov = 'rcov -Ilib --exclude /gems/,/Library/,/usr/,spec --html'

    system("#{rcov} test/tc_*.rb test/vcs/tc_*.rb")

  end # task :coverage

end # namespace :test
