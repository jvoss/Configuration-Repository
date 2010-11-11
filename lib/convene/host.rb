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

require 'ftools'
require 'logger'
require 'observer'
require 'snmp'
require 'yaml'
require 'convene/constants'
require 'convene/errors'
require 'convene/task'

module Convene
  
  class Host
    
    include Comparable
    include Observable
    
    SNMP_DEFAULT_COMMUNITY = 'public'
    SNMP_DEFAULT_PORT      = 161
    SNMP_DEFAULT_TIMEOUT   = 3
    SNMP_DEFAULT_RETRIES   = 2
    SNMP_DEFAULT_VERSION   = :SNMPv2c
    
    attr_reader :hostname, :log, :username, :password, :tasks
    
    # Initializes a new host object:
    #
    # ===Example 
    # host = Host.new( :hostname     => 'host.domain.tld',
    #                  :username     => 'user',
    #                  :password     => 'pass',
    #                  :log          => Logger.new(STDOUT),
    #                  :snmp_options => {},
    #                  :taskfile     => '' )
    # 
    # snmp_options can contain any options available from the 'snmp' gem.
    #
    # Force a particular task by supplying a filename of the task. See
    # load_task_file for more information.
    #
    def initialize(options = {}) 
    
      @hostname     = options[:hostname]
      @log          = options[:log]          || Logger.new(STDOUT)
      @username     = options[:username]
      @password     = options[:password]
      @snmp_options = options[:snmp_options] || {}
      @tasks        = []
      
      options[:taskfile].nil? ? _snmp_initialize : load_task_file(options[:taskfile])
      
    end # def initialize
    
    def ==(host)
      
      @hostname == host.to_s
      
    end # def ==
    
    # Loads the specified task YAML. Tasks are found in the order:
    #  taskfile = a filename itself
    #  taskfile = User's <home directory>/.convene/tasks/<taskfile>.yaml
    #  taskfile = Pre-packaged drivers <taskfile>.rb
    #
    # Task filenames should be all lowercased. 
    #
    def load_task_file(taskfile)
      
      filename = nil
      
      locations = [ taskfile,
                    HOME_DIR + "/tasks/#{taskfile}.yaml",
                    BASE_DIR + "/tasks/#{taskfile}.yaml"  ]
      
      locations.each do |location|
        if File.exist?(location)
          filename = location
          break # locations.each
        end # File.exist?
      end # locations.each
      
      raise HostError, "Unable to locate task file #{taskfile}" if filename.nil?
      
      @log.debug "Loading taskfile: #{filename}"
      task = YAML.load_file(filename)
      
      @tasks.push task
      
    end # def load_task_file 
    
    # Runs all tasks
    #
    def process
      
      @log.info "Processing host: #{@hostname}"
      
      _snmp_fingerprint if @tasks.empty?
      
      raise HostError, "No tasks are loaded" if @tasks.empty?
      
      run_tasks
      
    end # def process
    
    # Runs a specified task object
    #
    def run_task(task)
      
      @log.debug "Running task: #{task.name}"
      
      files = task.run(@hostname, @username, @password)
      
      changed
      notify_observers(self, files)
      
    end # def run_task
    
    # Runs all load tasks
    #
    def run_tasks()
      
      @tasks.each do |task|
        
        puts run_task(task)
        
      end # @tasks.each
      
    end # run_tasks
    
    # Returns the hostname of the object. Used for comparisons
    #
    def to_s
      
      @hostname
      
    end # def to_s
    
    private
    
    # Detects which type of host to load based on the SNMP response of 
    # 'sysDescr'. Extends the proper module from lib/hosts.
    #
    def _snmp_fingerprint
      
      begin
        
        # Match the first word returned from the SNMP sysDescr
        # (usually a manufacturer) and attempt to load a driver named that.
        manufacturer = _snmp_sysdescr.match(/^(\w+)/).to_s
        
        # Example: manufacturer = 'Cisco'
        load_task_file(manufacturer)
        
      rescue => e
        
        true_log_str  = "#{@hostname}: SNMP timeout"
        false_log_str = "#{@hostname}: #{e}"
        
        e.is_a?(SNMP::RequestTimeout) ? @log.warn(true_log_str)  \
                                      : @log.warn(false_log_str)

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
      @snmp_options = snmp_defaults.merge(@snmp_options.dup)
      
      # Fingerprint the device using SNMP sysDescr
      _snmp_fingerprint
      
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
  
end # module Convene
