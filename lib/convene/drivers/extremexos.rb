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
require 'convene/transport/telnet'

module Convene
  
  class Host
    
    module Extremexos
      
      # Retrieve a device's startup configuration via Telnet.
      # Returns a hash of arrays with the keys being a filename.
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
       
          raise HostError, e.to_s
       
       end # begin
       
        startup_config.pop
        startup_config.shift until startup_config[0] =~ /^# Module/
 
        return {'config' => startup_config}
        
      end # config
      
    end # module Extremexos
    
  end # class Host
  
end # module Convene
