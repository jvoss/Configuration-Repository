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
require 'logger'
require 'test/unit'
require 'test/test_helpers'
require 'test/mocks/dns'
require 'test/mocks/host'
require 'convene/manager'

module Convene

  class Test_manager < Test::Unit::TestCase
    
    def setup
      @convene = Manager.new( :repository => TEST_OPTIONS[:repository],
                                :log        => Logger.new(nil),
                                :username   => 'username',
                                :password   => 'password',
                                :regex      => /(example|domain)/,
                                :blacklist  => ['blacklisted.domain.tld']
                              )
    end # def setup
    
    def teardown
      if File.exists?(TEST_OPTIONS[:repository])
        assert FileUtils.rm_r(TEST_OPTIONS[:repository])
      end
    end # def teardown
    
    def test_add_host
      host = Convene::Host.new(:hostname => 'test.domain.tld')
      
      assert @convene.add_host(host)
      assert @convene.hosts.include?(host)
      
      # Assert no crash on duplicate hosts, non-regex matches, blacklist matches
      # (log messages occur)
      #
      assert_nothing_raised do
        assert @convene.add_host(host)        # duplicate
        
        testhost = Mocks::Host.new(:hostname => 'host.tld')
        assert @convene.add_host(testhost)    # non-regex match
        
        blacklisted = Mocks::Host.new(:hostname => 'blacklisted.domain.tld')
        assert @convene.add_host(blacklisted) # blacklisted
      end # assert_nothing_raised
      
    end # def test_add_host
    
    def test_add_host_string
      assert @convene.add_host_string('user:pass@host.domain.tld')
      assert @convene.hosts.include?('host.domain.tld')
      
      # Test adding domains
      assert @convene.add_host_string('example.com', :domain)
      assert @convene.hosts.include?('foo.example.com')
      assert @convene.hosts.include?('host.domain.tld')
      assert @convene.hosts.include?('host1.example.com')
      assert @convene.hosts.include?('host2.example.com')
      assert @convene.hosts.include?('host3.example.com')
    end # def test_add_host_string
    
    def test_blacklist
      assert @convene.respond_to?(:blacklist)
      assert @convene.blacklist.kind_of?(Array)
    end # def test_blacklist
    
    def test_default_password
      assert_equal 'password', @convene.default_password
      @convene.default_password = 'testing'
      assert_equal 'testing', @convene.default_password
    end # def test_default_password
    
    def test_default_username
      assert_equal 'username', @convene.default_username
      @convene.default_username = 'usertest'
      assert_equal 'usertest', @convene.default_username
    end # def test_default_username
    
    def test_delete_host
      @convene.delete_host('test.domain.tld')
      @convene.delete_host('host.domain.tld')
      
      assert_equal 0, @convene.hosts.size
    end # def test_delete_host
    
    def test_hosts
      assert @convene.respond_to?(:hosts)
      assert @convene.hosts.kind_of?(Array)
    end # def test_hosts
    
    def test_import_blacklist
      @convene.import_blacklist("#{File.dirname(__FILE__)}/files/test_blacklist.txt")
      
      assert_equal 4, @convene.blacklist.size
      assert       @convene.blacklist.include?('hostA.domain.tld')
      assert       @convene.blacklist.include?('hostB.domain.tld')
      assert       @convene.blacklist.include?('hostC.domain.tld')
    end # def test_import_blacklist
    
    def test_import_file
      @convene.import_file("#{File.dirname(__FILE__)}/files/test_txt.txt", :host)
      @convene.import_file("#{File.dirname(__FILE__)}/files/test_csv.csv", :host)
      
      assert_equal 5, @convene.hosts.size
      assert       @convene.hosts.include?('host1.domain1.tld1')
      assert       @convene.hosts.include?('host2.domain2.tld2')
      assert       @convene.hosts.include?('host3.domain3.tld3')
      assert       @convene.hosts.include?('host4.domain4.tld4')
      assert       @convene.hosts.include?('host.domain.tld')
    end # def test_import_file
    
    def test_run_tasks
      snmp_options = { :Port      => 10161,
                       :Community => 'ppuuubllicc',
                       :Version   => :SNMPv1,
                       :Timeout   => 7,
                       :Retries   => 1 }
      
      test_options = { :hostname     => 'host.domain.tld',
                       :username     => 'username',
                       :password     => 'password',
                       :log          => Logger.new(nil),
                       :snmp_options => snmp_options
                      }
      
      host = Mocks::Host.new(test_options)
      @convene.add_host(host)
      
      assert @convene.run_tasks
    end # def test_run_tasks
    
    def test_repository
      assert @convene.respond_to?(:repository)
      assert @convene.repository.kind_of?(Repository)
    end # def test_repository
    
  end # class Test_manager

end # module Convene
