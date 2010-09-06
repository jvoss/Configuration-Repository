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
        
        host = process_record(record)

        if hosts.include?(host)
          
          CR.log.debug "Ignoring host \"#{host}\" -- duplicate"
          
          next # zone.transfer
          
        end # if hosts.include?(host)

        hosts.push host unless host.nil?
        
      end # zone.transfer

      return hosts
      
    end # def self.axfr
    
    # Processes Dnsruby RR object and returns desired target hostname
    #
    def self.process_record(record)
      
      host = nil
      
      if valid_record_type?(record)
        
        host = record.type == 'CNAME' ? record.rdata_to_string.chop \
                                      : record.name.to_s
        
      else
        
        CR.log.debug "Ignoring host \"#{record.name}\" -- type #{record.type}"
        
      end # valid_record_type?
      
      return host
      
    end # self.process_record
    
    # Returns true if Dnsruby RR object is acceptable for processing
    #
    def self.valid_record_type?(record)
    
      valid_record_type = record.type == 'A'    ||
                          record.type == 'AAAA' ||
                          record.type == 'CNAME'
                          
      return valid_record_type
    
    end # self.valid_record_type?
    
  end # module DNS
  
end # module CR
