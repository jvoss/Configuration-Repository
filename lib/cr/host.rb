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

require 'observer'
require 'snmp'

class CR
  
  class Host
    
    include Comparable
    include Observable
    
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
    # snmp_options can contain any options available from the 'snmp' gem.
    #
    # Force a particular driver by supplying class name for the driver argument:
    #   driver = CR::Host::Cisco
    #
    def initialize(hostname, username, password, snmp_options = {}, driver = nil)
      
      @driver       = driver
      @hostname     = hostname
      @username     = username
      @password     = password
      @snmp_options = snmp_options
      
      if @driver.nil?
        _snmp_initialize
      else
        _load_driver(@driver)
      end # driver.nil?
      
    end # def initialize
    
    def ==(host)
      @hostname == host.to_s
    end # def ==
    
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
      
      _snmp_fingerprint if @driver.nil?
      
      changed # indicate a change has occurred 
      notify_observers(self, config)
      
    end # def process
    
    # Returns the hostname of the object. Used for comparisons
    #
    def to_s
      @hostname
    end # def to_s
    
    private
    
    # Loads the specified driver class by extending its functionality into self
    #
    def _load_driver(driver)
      
      # Load all .rb files in hosts directory
      lib_dir      = File.dirname(__FILE__) + '/hosts'
      full_pattern = File.join(lib_dir, '*.rb')
      Dir.glob(full_pattern).each {|file| require file}
      
      CR.log.debug "Loading \"#{driver}\" driver"
      
      extend eval(driver)
      
    end # def _load_driver
    
    # Detects which type of host to load based on the SNMP repsponce of 
    # 'sysDescr'. Extends the proper module from lib/hosts.
    #
    def _snmp_fingerprint
      
      begin
        
        # Match the first word returned from the SNMP sysDescr
        # (usually a manufacturer) and attempt to load a driver named that.
        manufacturer = _snmp_sysdescr.match(/^(\w+)/).to_s
        
        # Example: manufacturer = 'Cisco'
        _load_driver(manufacturer)
        
      rescue
        
        CR.log.warn "No driver \"CR::Host::#{manufacturer}\" for #{@hostname}"
        
      end # begin
      
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
    
    # Returns SNMP value sysDescr.0 from host
    #
    def _snmp_sysdescr
      
      sysDescr = nil
      
      SNMP::Manager.open(@snmp_options) do |manager|
        
        response = manager.get(['sysDescr.0'])
        
        response.each_varbind do |var|
          sysDescr = var.value.to_s
        end # response.each_varbind
        
      end # SNMP::Manager.open
      
      return sysDescr
      
    end # def _snmp_sysdescr
    
  end # class Host
  
end # class CR
