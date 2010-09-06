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
require 'cr/dns'

## Mockup 

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

## end Mockup

module CRTest
  
  class Test_dns < Test::Unit::TestCase
    
    # Test Records
    A     = Dnsruby::RR.create("foo.domain.tld. 86400 A     192.168.1.1")
    AAAA  = Dnsruby::RR.create("bar.domain.tld. 86400 AAAA  FFFF::1")
    CNAME = Dnsruby::RR.create("foo.domain.tld. 86400 CNAME foo.domain.tld.")
    MX    = Dnsruby::RR.create("foo.domain.tld. 86400 MX 20 foo.example.com.")
    SOA   = Dnsruby::RR.create("srv.domain.tld. 864   SOA domain.tld. bar.domain.tld.")
    TXT   = Dnsruby::RR.create("domain.tld.     86400 TXT \"test txt\"")
    
    context "Zone transfers" do
      
      should "return a list of no duplicates and contain expected hosts" do
      
        expected_hosts = [ 'foo.example.com',
                           'host.domain.tld',
                           'host1.example.com',
                           'host2.example.com',
                           'host3.example.com'
                         ]
      
        hosts = CR::DNS.axfr('example.com')
        
        assert_equal expected_hosts, hosts
      
      end # should "return a list of no duplicates and contain expected hosts"
      
    end # context "Zone transfers"
    
    context "Processing records" do
      
      should "return a target hostname for valid records" do
        
        assert_equal "foo.domain.tld", CR::DNS.process_record(A)
        assert_equal "bar.domain.tld", CR::DNS.process_record(AAAA)
        assert_equal "foo.domain.tld", CR::DNS.process_record(CNAME)
        
      end # should "return a target hostname for valid records"
      
      should "return nil for invalid records" do
        
        assert_nil CR::DNS.process_record(MX)
        assert_nil CR::DNS.process_record(SOA)
        assert_nil CR::DNS.process_record(TXT)
        
      end # should "return nil for invalid records"
      
    end # context "Processing records"
    
    context "Validating record types" do
      
      should "return true when a valid type is given" do
        
        assert CR::DNS.valid_record_type?(A)
        assert CR::DNS.valid_record_type?(AAAA)
        assert CR::DNS.valid_record_type?(CNAME)
        
      end # should "return true when a valid type is given"
      
      should "return false when an invalid type is given" do
        
        assert !CR::DNS.valid_record_type?(MX)
        assert !CR::DNS.valid_record_type?(SOA)
        assert !CR::DNS.valid_record_type?(TXT)
        
      end # should "return false when an invalid type is given"
      
    end # context "Validating record types"
    
  end # class Test_dns
  
end # module CRTest
