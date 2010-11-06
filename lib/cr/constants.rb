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

require 'ftools'

class CR
  
  ARGUMENT_ERROR = 1
  NONFATAL_ERROR = 255
  
  BASE_DIR = File.dirname(__FILE__)
  HOME_DIR = File.expand_path('~') + '/.convene'
  
  SNMP_VERSION_MAP = { :SNMPv1 => '1', :SNMPv2c => '2c' }
  
end # class CR
