# Copyright 2010 Matthew J. Kosmoski
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

require 'convene/host'
require 'convene/errors'
require 'convene/transport/scp'

module Convene
  
  class Host
    
    module Ssg # ScreenOS
      
      # Retrieve a device's startup configuration via Telnet.
      # Returns a hash of arrays with the keys being a filename.
      #
      def config
      
        startup_config = []
        startup_config_tmp = ""
        
        begin

          scp = Transport::SCP.new(@hostname, @username, @password)
          
          startup_config_tmp = scp.download!("ns_sys_config")
          
        rescue => e
          
          raise HostError, e.to_s
          
        end # begin
        
        startup_config = startup_config_tmp.split(/\cM/) # Split on newlines.
        startup_config.shift # Remove header comment
        
        return {'ns_sys_config' => startup_config}
        
      end # config
      
    end # module Ssg
    
  end # class Host
  
end # module Convene
