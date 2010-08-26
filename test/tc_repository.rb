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
require 'fileutils'
require 'tmpdir'
require 'test/test_helpers'
require 'cr/repository'

module CRTest
  
  # FIXME This test needs severely overhauled
  
  class Test_repository < Test::Unit::TestCase
    
    TEST_REPO  = TEST_OPTIONS[:repository]
    TEST_VCS   = [:git]
    
    TEST_VCS.each do |vcs|
    
      context "Checking a repository" do
        
        setup do
          
          @repo = CR::Repository.new(TEST_REPO, vcs)
          
        end # setup
        
        teardown do
          
          FileUtils.rm_r(TEST_REPO) # remove testing directory
          
        end # teardown
        
        should "return true if it does exist" do
          
          assert @repo.exist?
          
        end # should "return true if it does exist"
        
        # FIXME Fix the following tests with host mockup objects
#        should "allow saving to a file" do
#          
#          assert @repo.save('testfile', 'TEST SAVE')
#          
#        end # should "allow saving to a file"
#        
#        should "allow reading from a file" do
#          
#          File.open("#{TEST_REPO}/testfile", 'w') do |file|
#            file.print "TEST SAVE"
#          end # File.open
#          
#          assert @repo.read('testfile').include?('TEST SAVE')
#          
#        end # should "allow reading from a file"
        
#        should "allow adding all files to a repository" do
#          
#          @repo.save(hostobj, TEST_OPTIONS)
#          
#          assert @repo.add_all
#          
#        end # should "allow adding all files to a repository" do
          
#        should "allow committing all files in a repository" do
#          
#          @repo.save(hostobj, TEST_OPTIONS)
#          @repo.add_all
#          
#          assert @repo.commit_all('TEST COMMIT')
#          
#        end # should "allow committing all files in a repository"
        
      end # context "Checking a repository"
    
    end # TEST_VCS.each
    
  end # class Test_repository
  
end # module CRTest