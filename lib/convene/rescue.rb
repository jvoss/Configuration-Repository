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

require 'snmp'
require 'convene/constants'
require 'convene/host'
require 'convene/errors'
require 'convene/log'

module Convene
  
  module Rescue
    
    def self.catch_fatal(err_obj)
        
      puts "#{err_obj}"
      exit ARGUMENT_ERROR
      
    end # def self.catch_fatal
    
    def self.catch_host(err_obj, host_obj)
      
      if err_obj.is_a? Convene::HostError
          
        host_obj.log.error "HostError: #{host_obj.hostname} - #{err_obj} -- skipping"
        
      end # if err_obj.is_a? Convene::HostError
      
      if err_obj.is_a? SNMP::RequestTimeout
        
        host_obj.log.error "SNMP timeout: #{host_obj.hostname} -- skipping"
        
      end # if err_obj.is_a? SNMP::RequestTimeout
      
    end # def self.catch_host
    
  end # module Recsue
  
end # module Convene
