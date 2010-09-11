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
require 'cr/parse'

## Mockup for parse_domain() 

module Dnsruby
  
  class ZoneTransfer
    
    def transfer(domain = 'example.com')
      
      records = [ RR.create("mail.#{domain}. 86400 MX 20 foo.example.com."),
                  RR.create("foo.#{domain}. 86400 A 192.168.1.1"),
                  RR.create("foo.#{domain}. 86400 A 192.168.2.1"),
                  RR.create("bar.#{domain}. 86400 CNAME foo.#{domain}."),
                  RR.create("srv.#{domain}. 864 SOA #{domain}. bar.#{domain}."),
                  RR.create("host0.#{domain}. 86400 CNAME host.domain.tld."),
                  RR.create("host1.#{domain}. 86400 A 192.168.1.2"),
                  RR.create("#{domain}. 86400 TXT \"test txt\""),
                  RR.create("host2.#{domain}. 86400 A 192.168.1.3"),
                  RR.create("host3.#{domain}. 86400 AAAA 1234::5"),
                  RR.create("srv.#{domain}. 86400 SRV 20 0 0 bar.#{domain}.")
                ]
      
      return records
      
    end # def transfer
    
  end # class ZoneTransfer
  
end # module Dnsruby

## end Mockup for parse_domain()

module CRTest
  
  class Test_parse < Test::Unit::TestCase
    
    ## helper methods ##
    
    # Test a file and make assertions
    # Uses TEST_OPTIONS as testing individual options is done in Host testing
    #
    def test_file(filename, test_host_string_hash, options, type)
      
      hosts = CR.parse_file(filename, options, type)
      
      assert_not_nil hosts
        
      hosts.each do |host|
        
        obj_hostname     = host.instance_variable_get(:@hostname)
        obj_username     = host.instance_variable_get(:@username)
        obj_password     = host.instance_variable_get(:@password)
        obj_snmp_options = host.instance_variable_get(:@snmp_options)
        
        obj_value = { :hostname => obj_hostname,
                      :username => obj_username,
                      :password => obj_password }
        
        msg = "Host #{obj_hostname} or attributes do " \
              "not exist in test_host_string_hash"
        assert test_host_string_hash.value?(obj_value), msg
        
        options[:snmp_options][:Host] = obj_hostname
          
        assert_equal options[:snmp_options], obj_snmp_options
        
      end # hosts.each
      
    end # def test_file
    
    ## end helper methods ##
    
    # test self.parse_blacklist(filename)
    #
    context "Parsing a file of blacklisted hostnames" do
      
      should "return an array of blacklisted hosts from a txt file with comments" do
          
        test_blacklist = [ 'hostA.domain.tld', 
                           'hostB.domain.tld', 
                           'hostC.domain.tld']
                           
        test_blacklist_file = 'test/files/test_blacklist.txt'
          
        assert_equal test_blacklist, CR.parse_blacklist(test_blacklist_file)
        
      end # should
      
    end # context
    
    # test self.parse_domain(domain, options)
    #
    context "Parsing a domain" do
      
      should "return an array of host objects" do
        
        hosts = CR.parse_domain('example.com', TEST_OPTIONS)
        
        hosts.each do |host|
          assert host.is_a? CR::Host
        end
        
      end # should "return an array of host objects"
      
    end # context "Parsing a domain"
    
    # test self.parse_file(filename, options, type)
    #
    context "Parsing a file of host strings" do
      
      should "return an array of host objects from a txt file with comments" do
        
        filename = 'test/files/test_txt.txt'
        
        hostnames = [ 'host1.domain1.tld1',
                      'host2.domain2.tld2',
                      'host3.domain3.tld3',
                      'host4.domain4.tld4'
                    ]

        CR.parse_file(filename, TEST_OPTIONS, :host).each do |host_obj|
          
          hostname = hostnames.shift
          options  = TEST_OPTIONS[:snmp_options].dup
          
          options[:Host] = hostname
          
          assert_equal hostname, host_obj.hostname
          assert_equal options,  host_obj.instance_variable_get(:@snmp_options)
          
        end # CR.parse_file
        
      end # should "return an array of host objects from a txt file with comments"
      
      should "return an array of host objects from a CSV file" do
        
        # Expected host string hash
        host_strings = { 'line1' => { :hostname => 'host.domain.tld',
                                      :username => 'user',
                                      :password => 'pass' }
                       } 
        
        # Inspect hosts for setting proper SNMP options
        options = { :snmp_options => { :Community => 'community',
                                       :Version   => :SNMPv1,
                                       :Port      => 69,
                                       :Timeout   => 4,
                                       :Retries   => 1,
                                       :Host      => 'host.domain.tld' }
                  }
                                
        options = TEST_OPTIONS.merge(options)
        
        test_file 'test/files/test_csv.csv', host_strings, options, :host
        
      end # should "return an array of host objects from a CSV file"
      
    end # context "Parsing a file of host strings"
    
    # test self.parse_host_string(host_string, options)
    #
    context "Parsing a host string" do
      
      should "return a filename when 'file:' is in the host string" do
        
        x = CR.parse_host_string('file:test/files/test_txt.txt', TEST_OPTIONS)
        
        assert 'test/files/test_txt.txt', x
        
      end # should "return a filename when 'file:' is in the host string"
      
      should "return an array when a host string is given" do

        TEST_HOST_STRINGS.each_key do |host_string|
          
          expected_array = []
          
          expected_array.push TEST_HOST_STRINGS[host_string][:hostname]
          expected_array.push TEST_HOST_STRINGS[host_string][:username]
          expected_array.push TEST_HOST_STRINGS[host_string][:password]
          
          response = CR.parse_host_string(host_string, TEST_OPTIONS)
         
          assert_equal expected_array, response
          
        end # TEST_HOST_STRINGS.each_key
        
      end # should "return an array when a host string is given"
      
    end # context "Parsing host strings"
    
  end # class Test_parse

end # module CRTest
