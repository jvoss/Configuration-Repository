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

module SNMP

  class Manager
    
    def initialize(config = {})
      @config = config
    end # def initialize
    
    def close
      return true
    end # def close
    
    def get(object_list)
      return PDU.new
    end # def get
    
    def open(config = {})
      manager = Manager.new(config)
      if block_given?
        begin
          yield manager
        ensure
          manager.close
        end
      end # if block_given?
    end # def open
    
  end # class Manager
  
  class PDU
    
    def initialize
      @varbind_list = [Varbind.new]
    end # def initialize
    
    def each_varbind(&block)
      @varbind_list.each(&block)
    end # def each_varbind
    
  end # class PDU
  
  class Varbind
    
    attr_reader :name, :value
    
    def initialize
      @name  = nil # currently makes no use of name
      
      @value = "Cisco IOS Software, C870 Software (C870-ADVIPSERVICESK9-M), Version 12.4(15)T6, RELEASE SOFTWARE (fc2)" \
               "Technical Support: http://www.cisco.com/techsupport" \
               "Copyright (c) 1986-2008 by Cisco Systems, Inc." \
               "Compiled Mon 07-Jul-08 20:49 by prod_rel_team"
    end # def initialize
    
  end # class Varbind
  
end # module SNMP
