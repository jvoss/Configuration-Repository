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
require 'convene/dns'
require 'test/mocks/dns'

module ConveneTest
  
  class Test_dns < Test::Unit::TestCase
    
    def setup
      # Set DNS logging to nil to avoid logging output
      ::Convene::DNS.instance_variable_set(:@log, Logger.new(nil))
      
      # Test Records
      @a     = Dnsruby::RR.create("foo.domain.tld. 86400 A     192.168.1.1")
      @aaaa  = Dnsruby::RR.create("bar.domain.tld. 86400 AAAA  FFFF::1")
      @cname = Dnsruby::RR.create("foo.domain.tld. 86400 CNAME foo.domain.tld.")
      @mx    = Dnsruby::RR.create("foo.domain.tld. 86400 MX 20 foo.example.com.")
      @soa   = Dnsruby::RR.create("srv.domain.tld. 864   SOA domain.tld. bar.domain.tld.")
      @txt   = Dnsruby::RR.create("domain.tld.     86400 TXT \"test txt\"")
    end # def setup
    
    def test_axfr
      expected_hosts = [ 'foo.example.com',
                         'host.domain.tld',
                         'host1.example.com',
                         'host2.example.com',
                         'host3.example.com'
                        ]
                        
      hosts = ::Convene::DNS.axfr('example.com')
      
      assert_equal expected_hosts, hosts
    end # def test_axfr
    
    def test_process_record
      assert_equal "foo.domain.tld", ::Convene::DNS.process_record(@a)
      assert_equal "bar.domain.tld", ::Convene::DNS.process_record(@aaaa)
      assert_equal "foo.domain.tld", ::Convene::DNS.process_record(@cname)
      
      assert_nil ::Convene::DNS.process_record(@mx)
      assert_nil ::Convene::DNS.process_record(@soa)
      assert_nil ::Convene::DNS.process_record(@txt)
    end # def test_process_record
    
    def test_valid_record_type
      assert ::Convene::DNS.valid_record_type?(@a)
      assert ::Convene::DNS.valid_record_type?(@aaaa)
      assert ::Convene::DNS.valid_record_type?(@cname)
      
      assert !::Convene::DNS.valid_record_type?(@mx)
      assert !::Convene::DNS.valid_record_type?(@soa)
      assert !::Convene::DNS.valid_record_type?(@txt)
    end # def test_valid_record_type
    
  end # class Test_dns
  
end # module ConveneTest
