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
require 'logger'
require 'test/unit'
require 'test/mocks/dns'
require 'test/test_helpers'
require 'cr/cli'
require 'cr/cr'

module CRTest
  
  class Test_options < Test::Unit::TestCase
    
    def setup
      @argv = ['--blacklist',      "#{File.dirname(__FILE__)}/files/test_blacklist.txt",
               '--domain',         "example.com",
               '--logfile',        "#{Dir.tmpdir}/crtestlogfile.log",
               '--hostname',       "host.domain.tld",
               '--repository',     TEST_OPTIONS[:repository],
               '--regex',          '/.*/',
               '--username',       'testuser',
               '--password',       'testpass',
               '--verbosity',      'info',
               '--snmp-community', 'publik',
               '--snmp-port',      '162',
               '--snmp-retries',   '4',
               '--snmp-timeout',   '40',
               '--snmp-version',   '1'
              ]
              
    end # def setup
    
    def teardown
      if File.exists?(TEST_OPTIONS[:repository])
        assert FileUtils.rm_rf(TEST_OPTIONS[:repository])
      end
      
      if File.exists?("#{Dir.tmpdir}/crtestlogfile.log")
        assert FileUtils.rm_rf("#{Dir.tmpdir}/crtestlogfile.log")
      end
    end # def teardown

    def test_parse_cmdline
      
      object = ::CR.parse_cmdline(@argv)
      
      host_options = object.instance_variable_get(:@default_host_options)
      
      # blacklist
      assert object.blacklist.is_a?(Array)
      assert object.blacklist.include?('hostA.domain.tld')
      assert object.blacklist.include?('hostB.domain.tld')
      assert object.blacklist.include?('hostC.domain.tld')
      
      # domain
      assert object.hosts.include?('foo.example.com')
      assert object.hosts.include?('host1.example.com')
      assert object.hosts.include?('host2.example.com')
      assert object.hosts.include?('host3.example.com')
      
      # log
      assert object.instance_variable_get(:@log).is_a?(Logger)
      
      # hostname
      assert object.hosts.include?('host.domain.tld')
      
      # repository
      assert_equal TEST_OPTIONS[:repository], object.repository.directory
      
      # regex
      assert_equal /.*/, object.repository.regex
      
      # username
      assert_equal 'testuser', object.default_username
      
      # password
      assert_equal 'testpass', object.default_password
      
      # verbosity
      assert_equal Logger::INFO, object.log.level
      
      # snmp community
      snmp_community = host_options[:snmp_options][:Community]
      assert_equal 'publik', snmp_community
      
      # snmp port
      snmp_port = host_options[:snmp_options][:Port]
      assert_equal 162, snmp_port
      
      # snmp retries
      snmp_retries = host_options[:snmp_options][:Retries]
      assert_equal 4, snmp_retries
      
      # snmp timeout
      snmp_timeout = host_options[:snmp_options][:Timeout]
      assert_equal 40, snmp_timeout
      
      # snmp version
      snmp_version = host_options[:snmp_options][:Version]
      assert_equal :SNMPv1, snmp_version
      
    end # def test_parse_cmdline
    
    def test_invalid_snmp_version
      @argv = ['--snmp-version', 'INVALID']
      
      assert_raises ArgumentError do
        ::CR.parse_cmdline(@argv)
      end # assert_raises
    end # def test_invalid_snmp_version
    
  end # class Test_options

end # module CRTest
