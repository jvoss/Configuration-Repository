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

require 'cr/host'
require 'cr/transport/scp'

class CR
  
  class Host
    
    module SSG # ScreenOS
      
      # Retrieve a device's startup configuration as an array via Telnet
      #
      def config
      
        startup_config = []
        startup_config_tmp = ""
        
        begin

          scp = Transport::SCP.new(@hostname, @username, @password)
          
          startup_config_tmp = scp.download!("ns_sys_config")
          
        rescue => e
          
          raise Host::NonFatalError, e.to_s
          
        end # begin
        
        startup_config = startup_config_tmp.split(/\cM/) # Split on newlines.
        startup_config.shift # Remove header comment
        
        return {'ns_sys_config' => startup_config}
        
      end # config
      
    end # module SSG
    
  end # class Host
  
end # class CR
