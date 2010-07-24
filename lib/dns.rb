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

require 'net/dns/resolver'
require 'net/dns/rr/srv'

module CR
  
  module DNS
    
    # Return an array of hostnames from an AXFR request for a domain
    #
    def self.axfr(domain)
      hosts = []
      
      resolver = Net::DNS::Resolver.new
#      resolver.logger = CR.log
      
      resolver.axfr(domain.to_s).answer.each do |record|
        next unless record.is_a?(Net::DNS::RR::A) or record.is_a?(Net::DNS::RR::AAAA)
        hosts.push record.name.chop # chop removes trailing period from answer
      end
      
      return hosts
    end # def self.axfr
    
  end # module DNS
  
end # module CR