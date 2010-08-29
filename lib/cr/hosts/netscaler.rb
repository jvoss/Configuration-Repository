# Copyright 2010 Matthew J. Kosmoski
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

require 'net/scp'
require 'cr/host'

module CR
  
  class Host
    
    module Netscaler
      
      # Error class for catching non-fatal SSH errors
      #
      class SSHError < RuntimeError; end
      
      # Retrieve a device's startup configuration as an array via Telnet
      #
      def config
      
        startup_config = []
        startup_config_tmp = ""
        
        Net::SCP.start(@hostname, @username, :password => @password) do |scp|
          startup_config_tmp = scp.download!("/nsconfig/ns.conf")
        end # Net::SCP.start
          
        startup_config = startup_config_tmp.split(/\r\n/) # Split on newlines.
        
        return startup_config
        
      end # config
      
    end # module Netscalar
    
  end # class Host
  
end # module CR
