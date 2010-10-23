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
require 'cr/transport/telnet'

class CR
  
  class Host
    
    module Extremexos
      
      # Retrieve a device's startup configuration as an array via Telnet
      #
      def config
      
        startup_config = []
        
        begin
       
          telnet = Transport::Telnet.new(@hostname, @username, @password)
          
          telnet.login do |session|
            
            session.cmd('disable clipaging')
            
            session.cmd('show config') do |line|
              startup_config.push(line)
            end # session.cmd('show config')
            
          end # telnet.login
       
       rescue => e
       
          raise Host::NonFatalError, e.to_s
       
       end # begin
       
        startup_config.pop
        startup_config.shift until startup_config[0] =~ /^# Module/
 
        return {'config' => startup_config}
        
      end # config
      
    end # module Extremexos
    
  end # class Host
  
end # class CR
