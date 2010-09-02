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

require 'dnsruby'

module CR
  
  module DNS
    
    # Return an array of hostnames from an AXFR request for a domain
    #
    def self.axfr(domain)
      
      hosts = []
      zone  = Dnsruby::ZoneTransfer.new
      
      zone.transfer(domain.to_s).each do |record|

        host = record.name.to_s
        type = record.type

        valid_record_type = type == 'A'    ||
                            type == 'AAAA' ||
                            type == 'CNAME'

        unless valid_record_type
          
          CR.log.debug "Ignoring host \"#{host}\" -- type #{type}"
          
          next # zone.transfer
          
        end # unless valid_record_type
        
        # Retrieve the CNAME target and remove trailing period
        host = record.rdata_to_string.chop if record.type == 'CNAME'
        
        if hosts.include?(host)
          
          CR.log.debug "Ignoring host \"#{host}\" -- duplicate"
          next # zone.transfer
          
        end # if hosts.include?(host)
        
        hosts.push host
        
      end # zone.transfer

      return hosts
      
    end # def self.axfr
    
  end # module DNS
  
end # module CR
