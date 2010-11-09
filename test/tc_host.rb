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
require 'convene/host'
require 'test/mocks/host'
require 'test/mocks/observer'
require 'test/mocks/snmp'

module ConveneTest
  
  class Test_host < Test::Unit::TestCase
    
    def setup
      @snmp_options = { :Port      => 10161,
                        :Community => 'ppuuubllicc',
                        :Version   => :SNMPv1,
                        :Timeout   => 7,
                        :Retries   => 1 }
      
      @test_options = { :hostname     => 'host.domain.tld',
                        :username     => 'username',
                        :password     => 'password',
                        :log          => Logger.new(nil),
                        :snmp_options => @snmp_options
                      }

      @host = Convene::Host.new(@test_options)
    end # def setup
    
    def test_comparable
      other_host = Convene::Host.new(@test_options)
      
      assert @host == 'host.domain.tld'
      assert_equal @host, other_host
    end # def test_comparable
    
    def test_config
      # Assert mock config is returned because a driver has not been loaded 
      # and therefor, overwritten.
      assert !@host.config.nil?
      assert @host.config.kind_of?(Hash)
    end # def test_config
    
    def test_driver
      assert @host.respond_to?(:driver)
      assert_equal nil, @host.driver
      
      test_options = @test_options.dup
      test_options[:driver] = 'cisco'
      
      host = Convene::Host.new(test_options)
      assert_equal Convene::Host::Cisco, host.driver
    end # def test_driver
    
    def test_hostname
      assert @host.respond_to?(:hostname)
      assert_equal @test_options[:hostname], @host.hostname
    end # def test_hostname
    
    def test_password
      assert @host.respond_to?(:password)
      assert_equal @test_options[:password], @host.password
    end # def test_password
    
    def test_process
      observer = Observer.new
      
      @host.add_observer(observer)
      @host.process
      
      assert       !observer.config.nil?
      assert_equal @host, observer.hostobj
    end # def test_process
    
    def test_snmp_options
      obj_snmp_options = @host.instance_variable_get(:@snmp_options)
      
      # Ensure SNMP options include the hostname
      snmp_options = @snmp_options.dup
      snmp_options[:Host] = @test_options[:hostname]
      
      assert_equal snmp_options, obj_snmp_options
    end # def test_snmp_options
    
    def test_to_s
      assert_equal @test_options[:hostname], @host.to_s
    end # def test_to_s
    
    def test_username
      assert @host.respond_to?(:username)
      assert_equal @test_options[:username], @host.username
    end # def test_username
    
    def test__snmp_fingerprint
      assert_nothing_raised do
        @host.send(:_snmp_fingerprint)
      end # assert_nothing_raised
      
      assert_equal ::Convene::Host::Cisco, @host.driver
      
      # A log message is generated when a driver cannot be loaded.
      # It should not terminate the script.
      #
      saved_const = ::Convene::Host::Cisco
      
      assert ::Convene::Host.send(:remove_const, :Cisco)
      
      assert_nothing_raised do
        @host.send(:_snmp_fingerprint)
      end # assert_nothing_raised
      
      # Reset the removed constant
      #
      assert ::Convene::Host.const_set(:Cisco, saved_const)
      
    end # def test__snmp_fingerprint
    
  end # class Test_host
  
end # module ConveneTest
