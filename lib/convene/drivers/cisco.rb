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
require 'convene/errors'
require 'convene/host'
require 'convene/transport/ssh'

module Convene
  
  class Host
    
    module Cisco
      
      # Retrieve a device's startup configuration via SSH.
      # Returns a hash of arrays with the keys being a filename.
      #
      def config
      
        startup_config = []
        
        begin
          
          ssh = Transport::SSH.new(@hostname, @username, @password)
          
          startup_config = ssh.exec!('show startup-config')
          
        rescue => e
          
          case
          
            when e.to_s.include?('could not execute command:')
              raise HostError, e.to_s
          
            when e.is_a?(Net::SSH::AuthenticationFailed)
              raise HostError, "Authentication Failed"
              
            when e.is_a?(Errno::ECONNREFUSED)
              raise HostError, e.to_s
              
            else
              raise e
          
          end # case
          
        end # begin
        
        startup_config.shift until startup_config[0] =~ /^version/
        startup_config.unshift("!\r\n") # add back beginning '!' on configuration
        
        return {'startup_config' => startup_config}
        
      end # config

    end # module Cisco
    
  end # class Host
  
end # module Convene
