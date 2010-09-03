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

require 'test/unit/testsuite'

require 'tc_core'
require 'tc_host'
require 'tc_log'
require 'tc_options'
require 'tc_parse'
require 'tc_repository'

require 'vcs/tc_git'

module CRTest

  class Test_all

    def self.suite

      suite = Test::Unit::TestSuite.new
      
      suite << Test_core.suite
      suite << Test_dns.suite
      suite << Test_host.suite
      suite << Test_log.suite
      suite << Test_options.suite
      suite << Test_parse.suite
      suite << Test_repository.suite
      
      suite << Test_git.suite
      
      return suite
      
    end # def self.suite

  end # class Test_all

end # module CRTest
