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

require 'dnsruby'

# Overwrites Dnsruby::ZoneTransfer.transfer to emulate records being received.
#
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
