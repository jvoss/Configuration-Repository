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
require 'fileutils'
require 'test/unit'
require 'tmpdir'
require 'test/mocks/host'
require 'test/test_helpers'
require 'cr/repository'

#module CRTest
#  
#  ### Host mockup object ###
#  
#  class Host < CR::Host
#  
#    def process
#      return { 'testfile' => ['test contents\r\n'] }
#    end # def process
#    
#  end # class Host
#  
#  ### Host mockup object ###
#  
#  class Test_repository < Test::Unit::TestCase
#    
#    TEST_REPO  = TEST_OPTIONS[:repository]
#    TEST_VCS   = [:git]
#
#    # TODO - Disable CR logger from displaying warning messages
#    
#    TEST_VCS.each do |vcs|
#    
#      context "Checking a repository" do
#        
#        should "return true if it does exist" do
#          
#          directory = TEST_REPO + 'TC_repository1'
#          repo      = CR::Repository.new(directory, //, vcs)
#          
#          assert repo.exist?
#          
#          assert FileUtils.rm_r(directory)
#          
#        end # should "return true if it does exist"
#        
#      end # context "Checking a repository"
#      
#      context "Working with a CR::Repository" do
#   
#        directory = TEST_REPO + 'TC_repository2'
#        
#        REPO = CR::Repository.new(directory, //, vcs)
#        
#        should "raise ArgumentError if an invalid VCS was initialized" do
#          
#          assert_raise ArgumentError do
#            CR::Repository.new(TEST_REPO, //, :invalid)
#          end
#          
#        end # should "raise ArgumentError if an invalid VCS was initialized"
#        
#        should "return a Repository object on successful initialization" do
#          
#          assert_kind_of(CR::Repository, REPO)
#          
#        end # should "return a Repository object on successful initialization"
#        
#        should "return a Repository object of VCS class when opened" do
#          
#          if vcs == :git
#            assert_kind_of(CR::Repository::Git, REPO.open)
#          end # if vcs == :git
#          
#        end # should "return a Repository object of VCS class when opened"
#        
#        should "save file contents properly and skip save when not changed" do
#          
#          host      = CRTest::Host.new('host.domain.tld', 'user', 'pass')
#          contents  = host.process
#          
#          assert_nothing_raised do
#            
#            REPO.save(host, contents)
#            
#          end # assert_nothing_raised
#          
#          # Save again 
#          # TODO write better test for this
#          
#          assert_nothing_raised do
#            
#            REPO.save(host, contents)
#            
#          end # assert_nothing_raised
#          
#        end # should "save file contents properly"
#        
#        should "raise when trying to save nil contents" do
#          
#          host     = CRTest::Host.new('host.domain.tld', 'user', 'pass')
#          contents = nil
#          
#          assert_raise RuntimeError do
#            REPO.save(host, contents)
#          end # assert_raise
#          
#        end # should "raise when trying to save nil contents"
#
#        should "log but not raise on nil files within contents" do
#          
#          host     = CRTest::Host.new('host.domain.tld', 'user', 'pass')
#          contents = {'testfile' => nil}
#          
#          assert_nothing_raised do
#            REPO.save(host, contents)
#          end # assert_nothing_raised
#          
#        end # should "log but not raise on nil files within contents"
#
#        should "read files properly" do
#          
#          host = CRTest::Host.new('host.domain.tld', 'user', 'pass')
#          
#          REPO.save(host, host.process)
#          
#          expected = host.process['testfile']
#          
#          assert_equal expected, REPO.read(host, 'testfile')
#          
#        end # should "read files properly"
#        
#        should "not raise when adding all files to VCS" do
#          
#          assert_nothing_raised do
#            REPO.add_all
#          end
#          
#        end # should "not raise when adding all files to VCS"
#        
#        should "not raise when committing all files to VCS" do
#          
#          assert_nothing_raised do
#            REPO.commit_all('test commit.')
#          end
#          
#        end # should "not raise when committing all files to VCS"
#        
#      end # context "Working with a CR::Repository"
#    
#      # FIXME Naming with ZZZZ's is a cheap hack with shoulda to get this
#      # context to run last!
#      context "ZZZZZ Test cleanup" do
#        
#        should "remove the testing directory" do
#          assert FileUtils.rm_r(TEST_REPO + 'TC_repository2')
#        end # should "remove the testing directory"
#        
#      end # context "Test cleanup"
#    
#    end # TEST_VCS.each
#    
#  end # class Test_repository
#  
#end # module CRTest