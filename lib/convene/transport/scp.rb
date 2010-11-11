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

# FIXME Add method that can download multiple files in the same session and update Task

require 'net/scp'

module Convene
  
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
  
end # module Convene
