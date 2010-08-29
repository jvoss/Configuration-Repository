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

require 'snmp'
require 'cr/hosts/cisco'
require 'cr/hosts/extremexos'
require 'cr/hosts/foundry'
require 'cr/hosts/netscaler'
require 'cr/hosts/screenos'

module CR
  
  class Host
    
    # TODO consider renaming the error handling for Host
    class NonFatalError < StandardError; end
    
    SNMP_DEFAULT_COMMUNITY = 'public'
    SNMP_DEFAULT_PORT      = 161
    SNMP_DEFAULT_TIMEOUT   = 3
    SNMP_DEFAULT_RETRIES   = 2
    SNMP_DEFAULT_VERSION   = :SNMPv2c
    
    attr_reader :hostname
    
    # Initializes a new host object:
    #
    # ===Example 
    # host = Host.new('host.domain.tld', 'user', 'pass')
    # 
    # snmp_options can contain any options available from the 'snmp' gem
    #
    def initialize(hostname, username, password, snmp_options = {})
      
      @hostname     = hostname
      @username     = username
      @password     = password
      @snmp_options = snmp_options
      
      _snmp_initialize
      
    end # def initialize
    
    # This method gets overwritten from loaded drivers by extend.
    # Defaults to nil in the event the driver is not loaded properly
    # and a call is made to retrieve a configuration.
    #
    def config
      
      nil
      
    end # def config
    
    # Returns the devices configuration in an array as specified in 
    # lib/hosts/<type> as extended by finger printing.
    #
    def process
      
      _snmp_fingerprint
      
      config
      
    end # def process
    
    private
    
    # Loads the specified driver class by extending its functionality into self
    #
    def _load_driver(klass)
      
      CR::log.debug "Loading \"#{klass}\" driver"
      
      extend klass
      
    end # def _load_driver
    
    # Detects which type of host to load based on the SNMP repsponce of 
    # 'sysDescr'. Extends the proper module from lib/hosts.
    #
    def _snmp_fingerprint
      
      sysDescr = nil
      
      SNMP::Manager.open(@snmp_options) do |manager|
        
        response = manager.get(['sysDescr.0'])
        
        response.each_varbind do |var|
          sysDescr = var.value.to_s
        end # response.each_varbind
        
      end # SNMP::Manager.open
      
      case sysDescr
        
        when /Cisco/      then _load_driver(Cisco)
        when /ExtremeXOS/ then _load_driver(ExtremeXOS)
        when /Foundry/    then _load_driver(Foundry)
        when /NetScaler/  then _load_driver(Netscaler)
        when /SSG/        then _load_driver(ScreenOS)
        
        #when /Force10/   then 'force10'
        
        else CR::log.warn "No suitable driver for #{@hostname}"
        
      end # case SysDescr
      
    end # def _snmp_fingerprint
    
    # Initialize SNMP options by using any specifics the user specified
    # and fill in the blanks with default options.
    #
    def _snmp_initialize
      
      # SNMP defaults
      snmp_defaults = { :Port      => SNMP_DEFAULT_PORT,
                        :Community => SNMP_DEFAULT_COMMUNITY,
                        :Version   => SNMP_DEFAULT_VERSION,
                        :Timeout   => SNMP_DEFAULT_TIMEOUT,
                        :Retries   => SNMP_DEFAULT_RETRIES }
      
      # Use hostname user originally supplied
      snmp_defaults[:Host] = @hostname
      
      # Use any specific settings the user supplied for SNMP
      @snmp_options = snmp_defaults.merge(@snmp_options)
      
    end # def _snmp_initialize
    
  end # class Host
  
end # module CR