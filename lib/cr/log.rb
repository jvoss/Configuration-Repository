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

require "logger"

class CR
  
  module Logging
  
    # Default logging configuration
    @@log                 = Logger.new(STDOUT)
    @@log.level           = Logger::DEBUG
    @@log.datetime_format = "%Y-%m-%d %H:%M:%S"
    
    # Provides access to Logger. 
    #
    # By default Logger is initialized to direct messages to STDOUT with a
    # level set to INFO. Command line options are also available to customize
    # logging information at runtime.
    #
    def log
      
      @@log
      
    end # def log
    
    def log=(logger)
      
      @@log = logger
      
    end # def log=
  
  end # module Logging
  
end # class CR
