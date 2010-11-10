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

require 'convene/host'

module Convene

  module Mocks
    
    class Host < ::Convene::Host
      
      def config
        super # ensure super method is executed
        return { 'testfile' => ['test contents\r\n'] }
      end # def config
      
      # Overwrite process method to bypass attempts to connect to a real device.
      #
      def process
        # set the driver instance variable so that snmp fingerprinting will not
        # occur.
        @driver = 'TESTING'
        super
        return { 'testfile' => ['test contents\r\n'] }
      end # def process
      
    end # class Host
    
  end # module Mocks

end # module Convene
