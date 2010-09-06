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
require 'test/test_helpers'
require 'cr/vcs/git'

module CRTest
  
  class Test_git < Test::Unit::TestCase
    
    TEST_REPO  = TEST_OPTIONS[:repository]
    
    # test self.repo_exist? for invalid repositories
    #
    context "Checking if an invalid repository exists" do
      
      should "return false" do
        
        assert_equal false, CR::Repository::Git.exist?(TEST_REPO)
        
      end # should "return false"
      
    end # context "Checking if an invalid repository exists"
    
    # test self.init(repository) - creating repositories
    #
    context "Initializing a repository" do
      
      should "create a directory, intialize git, and return a git object" do
        
        obj = CR::Repository::Git.init(TEST_REPO)
        
        assert_kind_of CR::Repository::Git, obj
        
        FileUtils.rm_r(TEST_REPO) # remove testing directory
        
      end # should "create a directory and return a git object"
      
    end # context "Initializing a repository"
    
    # test self.repo_exist? for valid repositories
    #
    context "Checking if a valid repository exists" do
      
      setup do
        
        CR::Repository::Git.init(TEST_REPO)
        
      end # setup
      
      teardown do
        
        FileUtils.rm_r(TEST_REPO) # remove testing directory
        
      end # teardown
      
      should "return true" do
        
        assert CR::Repository::Git.exist?(TEST_REPO)
        
      end # should "return true"
      
    end # context "Checking if a valid repository exists"
    
    # test self.commit_all for valid repositories
    #
    context "Commiting all changes" do
      
      setup do
        
        @repo = CR::Repository::Git.init(TEST_REPO)
        
      end # setup
      
      teardown do
        
        FileUtils.rm_r(TEST_REPO) # remove testing directory
        
      end # teardown
        
      should "return false if no commit was made" do
        
        assert !@repo.commit_all('Test commit.')
        
      end # should "return false if no commit was made"
      
      should "return git lib string if successful" do
        
        file = File.open("#{TEST_REPO}/testfile", 'w')
        file.syswrite "test content"
        file.close
        
        @repo.add('.')
        
        assert_equal String, @repo.commit_all('Test commit.').class
        
      end # should "not raise if successful"
      
    end # context "Committing all changes"
    
  end # class Test_options

end # module CRTest