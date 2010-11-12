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
require 'test/test_helpers'
require 'convene/parse'

module Convene
  
  class Test_parse < Test::Unit::TestCase
    
    include Parsing
    
    def setup
      @snmp_options = { :Community => 'community',
                        :Version   => :SNMPv1,
                        :Port      => 69,
                        :Timeout   => 4,
                        :Retries   => 1,
                        :Host      => 'host.domain.tld'
                      }
    end # def setup
    
    # Tests parse_csv_file through parse_file
    #
    def test_parse_csv_file
      # Expected host string array
      expected_host_strings = [ 'user:pass@host.domain.tld' ]
                      
      host_strings = parse_file('test/files/test_csv.csv', @snmp_options)
      
      host_strings.each do |host_string, options|
        assert_equal expected_host_strings.shift, host_string
        assert_equal @snmp_options, options
      end # host_strings.each
    end # def test_parse_csv_file
    
    # Test parse_txt_file through parse_file
    #
    def test_parse_txt_file
      filename = 'test/files/test_txt.txt'
      
      hostnames = [ 'host1.domain1.tld1',
                    'user2@host2.domain2.tld2',
                    'user3:pass3@host3.domain3.tld3',
                    'user4:pa:s@s4@host4.domain4.tld4'
                  ]
                  
      parse_file(filename, @snmp_options).each do |host_string|
          hostname = hostnames.shift
          assert_equal hostname, host_string[0]
      end # Convene.parse_file
    end # def test_parse_txt_file
    
    def test_parse_host_string
      
      TEST_HOST_STRINGS.each_key do |host_string|
          
        expected_hash = {}
        
        expected_hash[:hostname] = TEST_HOST_STRINGS[host_string][:hostname]
        expected_hash[:username] = TEST_HOST_STRINGS[host_string][:username]
        expected_hash[:password] = TEST_HOST_STRINGS[host_string][:password]
        expected_hash[:taskfile] = TEST_HOST_STRINGS[host_string][:taskfile]
        
        response = parse_host_string(host_string, TEST_OPTIONS)
       
        assert_equal expected_hash, response
      end # TEST_HOST_STRINGS.each_key
      
      assert_raises ::Convene::ConveneError do
        parse_host_string('blah://host.domain.tld', TEST_OPTIONS)
      end # assert_raise
      
    end # def test_parse_host_string

  end # class Test_parse

end # module Convene
