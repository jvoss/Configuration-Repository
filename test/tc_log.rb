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

require 'rubygems'
require 'test/unit'
require 'test/test_helpers'
require 'cr/cr'
require 'cr/log'

module CRTest
  
  class Test_log < Test::Unit::TestCase
    
    def setup
      @cr = ::CR.new(:repository => TEST_OPTIONS[:repository])
    end # def setup
    
    def teardown
      if File.exists?(TEST_OPTIONS[:repository])
        assert FileUtils.rm_r(TEST_OPTIONS[:repository])
      end
    end # def teardown
    
    def test_initialize_log
      assert @cr.respond_to?(:log)
    
      # Logging is set to STDOUT by default, filename == nil
      assert_equal nil, @cr.log.instance_variable_get(:@filename)
      assert_equal Logger::DEBUG, @cr.log.level
      assert_equal "%Y-%m-%d %H:%M:%S", @cr.log.datetime_format
      
    end # def test_initialize_log
    
  end # class Test_log

end # module CRTest
