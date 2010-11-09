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

require 'convene/cli'
require 'convene/dns'
require 'convene/host'
require 'convene/host_list'
require 'convene/log'
require 'convene/parse'
require 'convene/repository'

class Convene
  
  extend  CLI
  include Parsing
  
  attr_reader   :blacklist, :hosts, :log, :repository
  
  # Creates a new CR object.
  #
  #===Options
  # :blacklist    <- An array of blacklisted hostnames.
  # :log          <- Logger object or nil for default logging.
  # :regex        <- A Regexp that defines hosts to match and repository 
  #                  structure or nil. Overall match permits host, each submatch
  #                  determines file hierarchy.
  # :repository   <- A string containing the directory a repository exists, or 
  #                  where to create one. This argument is required.                     
  # :username     <- A string containing the default username to use with each 
  #                  host object or nil.
  # :password     <- A string containing the default password to use with each 
  #                  host object or nil.
  # :snmp_options <- Ruby SNMP library options hash.
  #
  #===Example
  # CR.new(:regex => '/path/to/repository')
  #
  def initialize(options = {}) 
    
    @blacklist = options[:blacklist] || [] # array of blacklisted hostnames
    @hosts     = HostList.new
    @log       = options[:log]       || _initialize_log
    @regex     = options[:regex]     || //
    
    @default_host_options = { :username     => options[:username],
                              :password     => options[:password],
                              :snmp_options => options[:snmp_options] ||= {},
                              :log          => @log
                            }
    
    _initialize_repository(options[:repository], @regex, :git)
    _validate_blacklist
    
  end # def initialize
  
  # Adds a host object to the host list. A host is checked to match regex,
  # not included in the blacklist, and not a duplicate.
  #
  def add_host(hostobj)
    
    raise "Argument not Convene::Host object" unless hostobj.is_a?(Convene::Host)
    
    case 
    
      when ! hostobj.hostname.match(@regex)
        @log.debug "Ignoring host (Regex): #{hostobj.hostname}"
    
      when @blacklist.include?(hostobj.hostname)
        @log.info "Ignoring host (Blacklist): #{hostobj.hostname}"
        
      when @hosts.include?(hostobj)
        @log.debug "Ignoring host (Duplicate): #{hostobj.hostname}"
        
      else
        @log.info "Adding host: #{hostobj.hostname}"
        
        hostobj.add_observer(@repository)
        
        @hosts << hostobj
        
    end # case
    
  end # def add_host
  
  # Adds a host or domain specified in host string format.
  # type = :host or type = :domain. See parse_host_string.
  #
  def add_host_string(host_string, type = :host, snmp_options = {})
    
    host_options = @default_host_options.dup
    
    host_options[:snmp_options] = snmp_options unless snmp_options.empty?
    
    host_options.merge! parse_host_string(host_string, host_options)
    
    if type == :domain
      
      DNS.instance_variable_set(:@log, @log)
      
      DNS.axfr(host_options[:hostname]).each do |hostname|
        
        host_options = host_options.merge(:hostname => hostname)
        add_host Convene::Host.new(host_options)
        
      end # DNS.axfr
      
    else
      
      add_host Convene::Host.new(host_options)
      
    end # if type == :domain
    
  end # def add_host_string
  
  # Returns the default password for new hosts
  #
  def default_password
    
    @default_host_options[:password]
    
  end # def default_password
  
  # Sets the default password for new hosts
  #
  def default_password=(password)
    
    @default_host_options[:password] = password
    
  end # def default_password=
  
  # Returns the default username for new hosts
  #
  def default_username
    
    @default_host_options[:username]
    
  end # def default_username
  
  # Sets the default username for new hosts
  #
  def default_username=(username)
    
    @default_host_options[:username] = username
    
  end # def default_username=

  # Deletes a host from consideration. Argument can be any Convene::Host 
  # comparable. i.e. hostname or Host object.
  #
  def delete_host(host)
    
    @log.info "Removed host: #{host}" if @hosts.delete(host)
    
  end # delete_host
  
  # Imports a blacklist txt file with a hostname per line
  #
  def import_blacklist(filename)
    
    @blacklist = [] unless @blacklist.is_a?(Array)
    
    parse_txt_file(filename).each do |host_string|
      
      @blacklist.push(host_string[0]) unless @blacklist.include?(host_string)
      
    end # parse_txt_file
    
  end # def import_blacklist
  
  # Imports supported file types (CSV or TXT). Type specifies either a 
  # :domain or :host
  #
  def import_file(filename, type)
    
    snmp_options = @default_host_options[:snmp_options]
   
    parse_file(filename, snmp_options).each do |host_string, options|
                        
      add_host_string(host_string, type, options)
    
    end # parse_file
    
  end # def import_file
  
  # Processes all hosts and commits changes to the database. A commit
  # message can be given or left nil to use the default.
  #
  def process_all(commit_msg = nil)
    
    commit_msg = "Convene Commit: Processed #{@hosts.size} hosts" if commit_msg.nil?

    @hosts.each{|host| host.process}
    
    @log.info "Committing changes to repository"
    
    @repository.commit_all(commit_msg) if @repository.changed?
    
    @log.info "Completed processing all hosts"
    
  end # def process_all
  
  private
  
  # Initializes Convene::Repository object
  #
  def _initialize_repository(directory, regex, type)
    
    @repository = Repository.new( :directory => directory,
                                  :log       => @log,
                                  :regex     => regex,
                                  :type      => type )
                                  
  end # def _initialize_repository
  
  # Validates a blacklist. If a user supplied a string during object creation
  # it is taken as a filename and passed to #import_blacklist. Otherwise an
  # array of hostnames supplied is used.
  #
  def _validate_blacklist
    
    import_blacklist(@blacklist) if @blacklist.is_a?(String)
    
    raise "Blacklist must be an array or filename" unless @blacklist.is_a?(Array)
    
  end # def _validate_blacklist
  
end # class Convene
