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

require 'net/telnet'

module CR
  
  module Transport
    
    class Telnet
      
      def initialize(hostname, username, password)
        
        @hostname = hostname
        @username = username
        @password = password
        
      end # def initialize
      
      # Yields Net::Telnet object back to caller after logging in
      #
      def login
      
        telnet = Net::Telnet::new("Host" => @hostname)
        telnet.login
        
        yield telnet
      
        telnet.close
        
      end # def login
      
    end # class Telnet
    
  end # module Transport
  
end # module CR
