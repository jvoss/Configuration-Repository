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
require 'logger'
require 'test/unit'
require 'test/test_helpers'
require 'cr'

module CRTest

  class Test_cr < Test::Unit::TestCase
    
    def setup
      @cr = CR.new( :repository => TEST_OPTIONS[:repository],
                    :log        => Logger.new(nil),
                    :username   => 'username',
                    :password   => 'password'
                  )
    end # def setup
    
    def teardown
      if File.exists?(TEST_OPTIONS[:repository])
        assert FileUtils.rm_r(TEST_OPTIONS[:repository])
      end
    end # def teardown
    
    def test_add_host
      host = CR::Host.new(:hostname => 'test.domain.tld')
      
      assert @cr.add_host(host)
      assert @cr.hosts.include?(host)
    end # def test_add_host
    
    def test_add_host_string
      assert @cr.add_host_string('user:pass@host.domain.tld')
      assert @cr.hosts.include?('host.domain.tld')
    end # def test_add_host_string
    
    def test_blacklist
      assert @cr.respond_to?(:blacklist)
      assert @cr.blacklist.kind_of?(Array)
    end # def test_blacklist
    
    def test_default_password
      assert_equal 'password', @cr.default_password
      @cr.default_password = 'testing'
      assert_equal 'testing', @cr.default_password
    end # def test_default_password
    
    def test_default_username
      assert_equal 'username', @cr.default_username
      @cr.default_username = 'usertest'
      assert_equal 'usertest', @cr.default_username
    end # def test_default_username
    
    def test_delete_host
      @cr.delete_host('test.domain.tld')
      @cr.delete_host('host.domain.tld')
      
      assert_equal 0, @cr.hosts.size
    end # def test_delete_host
    
    def test_hosts
      assert @cr.respond_to?(:hosts)
      assert @cr.hosts.kind_of?(Array)
    end # def test_hosts
    
    def test_import_blacklist
      @cr.import_blacklist("#{File.dirname(__FILE__)}/files/test_blacklist.txt")
      
      assert_equal 3, @cr.blacklist.size
      assert       @cr.blacklist.include?('hostA.domain.tld')
      assert       @cr.blacklist.include?('hostB.domain.tld')
      assert       @cr.blacklist.include?('hostC.domain.tld')
    end # def test_import_blacklist
    
    def test_import_file
      @cr.import_file("#{File.dirname(__FILE__)}/files/test_txt.txt", :host)
      @cr.import_file("#{File.dirname(__FILE__)}/files/test_csv.csv", :host)
      
      assert_equal 5, @cr.hosts.size
      assert       @cr.hosts.include?('host1.domain1.tld1')
      assert       @cr.hosts.include?('host2.domain2.tld2')
      assert       @cr.hosts.include?('host3.domain3.tld3')
      assert       @cr.hosts.include?('host4.domain4.tld4')
      assert       @cr.hosts.include?('host.domain.tld')
    end # def test_import_file
    
    def test_process_all
      assert false
    end # def test_process_all
    
    def test_repository
      assert @cr.respond_to?(:repository)
      assert @cr.repository.kind_of?(CR::Repository)
    end # def test_repository
    
  end # class Test_cr

end # module CRTest
