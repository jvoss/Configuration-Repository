# Copyright 2010 Andrew R. Greenwood and Jonathan P. Voss
#
# This file is part of Convene
#
# Convene is free software: you can redistribute it and/or modify it under 
# the terms of the GNU General Public License as published by the Free 
# Software Foundation, either version 3 of the License, or (at your option) 
# any later version.
#
# Convene is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License 
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with Convene. If not, see <http://www.gnu.org/licenses/>.
#

require 'rubygems'
require 'test/unit'
require 'fileutils'
require 'test/test_helpers'
require 'convene/vcs/git'

module Convene
  
  class Test_vcs_git < Test::Unit::TestCase
    
    def setup
      @directory = TEST_OPTIONS[:repository]
      
      assert Repository::Git.init(@directory)
      @git = Repository::Git.open(@directory, :log => Logger.new(nil))
    end # def setup
    
    def teardown
      if File.exists?(@directory)
        assert FileUtils.rm_r(@directory)
      end
    end # def teardown
    
    def test_init
      # Assert it raises because the repository was already initialized
      assert_raises RuntimeError do
        assert Repository::Git.init(@directory)
      end # assert_raises
    end # def test_init
    
    def test_commit_all
      assert !@git.commit_all('test')
      
      contents = ['testfile']
      
      file = File.open("#{@directory}/testfile", 'w')
      
      contents.each do |line|
        file.syswrite line
      end # contents.each
    
      file.close
      
      assert @git.add('.')
      assert @git.commit_all('test')
    end # def test_commit_all
    
    def test_exist?
      assert  Repository::Git.exist?(@directory)
      assert !Repository::Git.exist?("#{@directory}2")
    end # def test_exist?
    
  end # class Test_vcs_git
  
end # module Convene
