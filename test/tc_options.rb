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
require 'shoulda'
require 'test/test_helpers'
require 'cr/options'

module CRTest
  
  class Test_options < Test::Unit::TestCase
    
    TEST_LOG   = TEST_OPTIONS[:log]
    TEST_REPO  = TEST_OPTIONS[:repository]
    TEST_REGEX = TEST_OPTIONS[:regex]
    
    # test initialize(log, repository, regex = //)
    #
    context "Initializing a options object" do
      
      should "return an object if valid options were supplied" do
        
        obj = CR::Options.new(TEST_LOG, TEST_REPO, TEST_REGEX)
        
        assert_equal TEST_LOG,    obj.log
        assert_equal TEST_REPO,   obj.repository
        assert_equal TEST_REGEX,  obj.regex
        
        assert_kind_of CR::Options, obj
        assert_kind_of Regexp,      obj.regex
        
      end # should "return an object if valid options were supplied"
      
      should "have STDOUT as log if nil was supplied" do
        
        assert_equal :STDOUT, CR::Options.new(nil, TEST_REPO, TEST_REGEX).log
        
      end # should "raise have STDOUT as log if nil was supplied"
      
      should "raise if a repository was not supplied" do
        
        assert_raise CR::Options::ArgumentError do
          CR::Options.new(TEST_LOG, nil, TEST_REGEX)
        end
        
      end # should "raise if a repository was not supplied"
      
      should "raise if an invalid regular expression was supplied" do
        
        assert_raise CR::Options::ArgumentError do
          CR::Options.new(TEST_LOG, TEST_REPO, 'testing')
        end
        
      end # should "raise if an invalid regular expression was supplied"
      
    end # context "Initializing a options object"
    
  end # class Test_options

end # module CRTest