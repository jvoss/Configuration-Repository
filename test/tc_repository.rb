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
require 'test/mocks/host'
require 'test/test_helpers'
require 'cr/repository'

module CRTest
  
  class Test_repository < Test::Unit::TestCase
    
    TEST_REPO = TEST_OPTIONS[:repository]
    
    def setup
      @repositories = {}
      
      @host = CR::Host.new(:hostname => 'test.domain.tld', :log => Logger.new(nil))
      
      options = { :directory => TEST_REPO,
                  :log       => Logger.new(nil),
                  :regex     => //,
                }
      
      git_options = options.dup.merge(:type => :git)
      
      @repositories[:git] = ::CR::Repository.new(git_options)
    end # def setup
    
    def teardown
      if File.exists?(TEST_OPTIONS[:repository])
        assert FileUtils.rm_r(TEST_OPTIONS[:repository])
      end
    end # def teardown
      
    def test_add_all
      @repositories.each_value do |repo|
        assert repo.add_all
      end # @repositories.each_value
    end # def test_add_all
    
    def test_add_host
      @repositories.each_value do |repo|
        assert repo.add_host(@host)
      end # @repositories.each_value
    end # def test_add_host
    
    def test_changed?
      @repositories.each_value do |repo|
        assert repo.changed?
        
        repo.commit_all('message')
        
        assert !repo.changed?
      end # @repositories.each_value
    end # def test_changed?
    
    def test_commit_all
      @repositories.each_value do |repo|
        assert repo.commit_all('test message')
      end # @repositories.each_value
    end # def test_commit_all
    
    def test_config_user_email
      @repositories.each_value do |repo|
        assert_nothing_raised do 
          repo.config_user_email('test@testing.org')
        end # assert_nothing_raised
      end # @repositories.each_value
    end # def test_config_user_email

    def test_config_user_name
      @repositories.each_value do |repo|
        assert_nothing_raised do 
          repo.config_user_name('Testing')
        end # assert_nothing_raised
      end # @repositories.each_value
    end # def test_config_user_name
    
    def test_exist?
      @repositories.each_value do |repo|
        assert repo.exist?
      end # @repositories.each_value
    end # def test_exist?
    
    def test_init
      @repositories.each_value do |repo|
        # Repo already initialized
        assert_raises RuntimeError do
          repo.init
        end # assert_raises
      end # @repositories.each_value
    end # def test_init
    
    def test_open
      @repositories.each_pair do |type, repo| 
        assert_kind_of(::CR::Repository::Git, repo.open) if type == :git
      end # @repositories.each_pair
    end # def test_open
    
    def test_read
      config   = @host.process
      filename = config.keys[0]
      contents = config.values[0]
      
      @repositories.each_value do |repo|
        repo.save_host(@host, config)
        
        assert_equal contents, repo.read(@host, filename)
      end # @repositories.each_value
    end # def test_read
    
    def test_save_host
      config = @host.process
      
      @repositories.each_value do |repo|
        assert repo.save_host(@host, config)
      end # @repositories.each_value
    end # def test_save_host
    
    def test_update
      config = @host.process
      
      @repositories.each_value do |repo|
        assert repo.update(@host, config)
      end # @repositories.each_value
    end # def test_update
    
  end # class Test_repository
  
end # module
