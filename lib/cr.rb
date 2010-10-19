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

require 'cr/constants'
require 'cr/dns'
require 'cr/host'
require 'cr/log'
require 'cr/options'
require 'cr/parse'
require 'cr/repository'

class CR
  
  extend CommandLine
#  extend Logging # TODO Integrate logging so that multiple instances can have different logs
  
  include Parsing
  
  VERSION = '0.1.0'
  
  attr_accessor :username, :password
  attr_reader   :blacklist, :hosts, :repository
  
  def initialize(options = {}) 
    
    @blacklist    = options[:blacklist] || [] # array of blacklisted hostnames
    @username     = options[:username]
    @password     = options[:password]
    @hosts        = []
#    @log
    @regex        = options[:regex] || //
    @repository   = Repository.new(options[:repository], @regex, :git)
    @snmp_options = options[:snmp_options] || {}
    
    _validate_blacklist
    
  end # def initialize
  
  def add_host(hostobj)
    
    raise "Argument not CR::Host object" unless hostobj.is_a?(CR::Host)
    
    case 
    
      when ! hostobj.hostname.match(@regex)
        CR.log.debug "Ignoring host (Regex): #{hostobj.hostname}"
    
      when @blacklist.include?(hostobj.hostname)
        CR.log.info "Ignoring host (Blacklist): #{hostobj.hostname}"
        
      when @hosts.include?(hostobj)
        CR.log.debug "Ignoring host (Duplicate): #{hostobj.hostname}"
        
      else
        CR.log.info "Adding host: #{hostobj.hostname}"
        
        hostobj.add_observer(@repository)
        
        @hosts << hostobj
        
    end # case
    
  end # def add_host
  
  # Adds a domain of hosts via AXFR request for an argument specified in
  # host string format.
  #
  def add_domain_string(host_string, snmp_options = {})
    
    # TODO Refactor this with add_host_string
    if host_string.match(/file:(.*)/)
      
      import_file $1, :domain
      
    else
    
      options = { :username => @username,
                  :password => @password  }
      
      options = options.merge(snmp_options.dup)
      
      domain, user, pass, driver = parse_host_string(host_string, options)
      
      DNS.axfr(domain).each do |hostname|
        
        add_host CR::Host.new(hostname, user, pass, @snmp_options, driver)
        
      end # DNS.axfr
    
    end # if
    
  end # def add_domain_string
  
  # Adds a host specified in host string format
  #
  def add_host_string(host_string, snmp_options = {})
    
    if host_string.match(/file:(.*)/)
      
      import_file $1, :host
      
    else
    
      options = { :username => @username,
                  :password => @password }
                  
      options = options.merge(snmp_options.dup)
      
      hostname, user, pass, driver = parse_host_string(host_string, options)
        
      add_host CR::Host.new(hostname, user, pass, @snmp_options, driver)
    
    end # if host_string.match
    
  end # def add_host_string

  # Deletes a host. Argument can be any CR::Host comparable. I.e. hostname
  # or Host object.
  #
  def delete_host!(host)
    
    CR.log.info "Removed host: #{host}" if @hosts.delete(host)
    
  end # delete_host!
  
  # Imports a blacklist txt file with a hostname per line
  #
  def import_blacklist(filename)
    
    parse_txt_file(filename).each do |host_string|
      @blacklist.push(host_string[0]) unless @blacklist.include?(host_string)
    end
    
  end # def import_blacklist
  
  # Imports supported file types (CSV or TXT). Type specifies either a 
  # :domain or :host
  #
  def import_file(filename, type)
   
    parse_file(filename, @snmp_options).each do |host_string, options|
    
      type == :domain ? add_domain_string(host_string, options) :
                        add_host_string(host_string, options)
    
    end # parse_file
    
  end # def import_file
  
  # Processes all hosts and commits changes to the database. A commit
  # message can be given or left nil to use the default.
  #
  def process_all(commit_msg = nil)
    
    commit_msg = "CR Commit: Processed #{@hosts.size} hosts" if commit_msg.nil?
    
    @hosts.each{ |host| host.process }
    @repository.commit_all(commit_msg)
    
  end # def process_all
  
  private
  
  # Validates a blacklist. If a user supplied a string during object creation
  # it is taken as a filename and passed to #import_blacklist. Otherwise an
  # array of hostnames supplied is used.
  #
  def _validate_blacklist
    
    # TODO fix the juggling of @blacklist variable?
    if @blacklist.is_a?(String)
      
      file       = @blacklist
      @blacklist = []
      
      import_blacklist(file)
      
    end # if @blacklist.is_a?(String)
    
    raise "Blacklist must be an array or filename" unless @blacklist.is_a?(Array)
    
  end # def _validate_blacklist
  
end # class CR
