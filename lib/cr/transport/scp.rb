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

require 'net/scp'

class CR
  
  module Transport
    
    class SCP
      
      def initialize(hostname, username, password)
        
        @hostname = hostname
        @username = username
        @password = password
        
      end # def initialize
      
      # Downloads filename from the remote device
      #
      def download!(filename)
        
        response = nil
        
        Net::SCP.start(@hostname, @username, :password => @password) do |scp|
          response = scp.download!(filename)
        end # Net::SCP.start
        
        return response
        
      end # def download!
      
    end # class SCP
    
  end # module Transport
  
end # class CR
