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
# along with CR. If not, see <http://www.gnu.org/licenses/>.
#

namespace :test do

  desc 'Measures test coverage'
  task :coverage do

    rm_f 'coverage'

    rcov = 'rcov -Ilib --exclude /gems/,/Library/,/usr/,spec --html'

    result = system("#{rcov} test/tc_*.rb test/vcs/tc_*.rb")

    if result == false

      puts 'rcov, or one of its dependencies, is not available.'
      puts 'Install it with: gem install rcov'

    end # if

  end # task :coverage

end # namespace :test
