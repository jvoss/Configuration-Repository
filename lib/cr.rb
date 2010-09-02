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

require "csv"
require 'rubygems'
require 'cr/constants'
require 'cr/dns'
require 'cr/host'
require 'cr/log'
require 'cr/options'
require 'cr/repository'

module CR
  
  VERSION = '0.1.0'
    
  # Creates an array of CR::Host objects from an array of host_strings.
  #
  # A list of host_strings can contain hostnames (type = :host) or a list
  # of domain names (type = :domain).
  #
  # See parse_host_string for information about host_string formatting.
  #
  #---
  #TODO: Refactor
  #+++
  #
  def self.create_hosts(host_strings, options, type)
    
    host_objects = []
    
    host_strings.each do |host|
      
      hosts = []
        
      host_info = parse_host_string(host, options)
        
      if host_info.is_a?(Array)
      
        target, username, password = parse_host_string(host, options)
        
        if type.to_sym == :domain
      
          DNS.axfr(target).each do |hostname|
            
            hosts.push [hostname, username, password, options[:snmp_options]]
          
          end # DNS.axfr
        
        elsif type.to_sym == :host
          
          hosts.push [target, username, password, options[:snmp_options]]
        
        else
        
          raise "Invalid host string type -- #{type}"
        
        end # if type
      
        hosts.each do |host|
          
          unless host[0].match(options[:regex])
            @@log.debug "Ignoring host (Regex): #{host[0]}"
            next
          end 
          
          if options[:blacklist].include?(host[0])
            @@log.debug "Ignoring host (Blacklist): #{host[0]}"
            next
          end
          
          @@log.debug "Adding host: #{host[0]}"
          
          host_objects.push CR::Host.new(host[0], host[1], host[2], host[3])
          
        end # hosts.each
      
      else # host_info must be a filename
        
        host_objects = parse_file(host_info, options, type)
      
      end # if host_options.is_a?(Array)
      
    end # host_strings.each
    
    return host_objects
    
  end # def self.create_hosts
    
  # Parses file and returns an array of blacklisted hostnames. Text files are
  # the only file types currently supported.
  #
  def self.parse_blacklist(filename)
    
    blacklist = []
    
    File.open(filename).each do |line|
      # ignore comment lines that start with '#'
      blacklist.push(line.chomp) unless line =~ /^[#|\n]/
    end # File.open
    
    return blacklist
    
  end # def self.parse_blacklist
  
  # Parses filename and returns an array of CR::Host objects. Files accepted
  # are text files with each line containing a valid host string or a CSV
  # in the following format:
  #
  # host_string,snmp_community,snmp_version,snmp_port,snmp_timeout,snmp_retries
  #
  # See parse_host_string for more information about host string formatting.
  #
  def self.parse_file(filename, options, type)
    
    host_strings = []
    options      = options.dup
    
    begin
      
      if File.extname(filename) == '.csv'
        
        CSV.open(filename, 'r', ',') do |row|
          
          host_string = row[0]
          
          snmp_options = { :Community => row[1],
                           :Version   => SNMP_VERSION_MAP.invert[row[2]],
                           :Port      => row[3].to_i,
                           :Timeout   => row[4].to_i,
                           :Retries   => row[5].to_i }
                           
          options[:snmp_options] = options[:snmp_options].merge(snmp_options)
          
          host_strings.push(host_string)
          
        end # CSV.open
        
      else # != '.csv'
      
        File.open(filename).each do |line|
          # ignore comment lines that start with '#'
          host_strings.push(line.chomp) unless line =~ /^[#|\n]/
        end
      
      end # if
      
    rescue Errno::ENOENT => e
      
      puts e
      exit ARGUMENT_ERROR
      
    end # begin
    
    return create_hosts(host_strings, options, type)
    
  end # def self.parse_file
  
  # Parses a host string into hostname, username, and password.
  # 
  # Valid host strings are:
  #   hostname.domain.tld
  #   user@hostname.domain.tld
  #   user:pass@hostname.domain.tld
  #
  #   file:filename.txt
  #
  # Domains can also be valid host strings: user:pass@domain.tld
  #
  # If a filename is specified with file: before the name, the filename
  # will be returned. This is done for filename detection on the command-line
  # and further file processing is done in the caller. 
  #
  def self.parse_host_string(host_string, options)
    
    filename = nil
    hostname = nil
    username = options[:username]
    password = options[:password]
    
    if host_string.include?('file:')
      
      filename = host_string.split('file:')[1]
      
    end # if
    
    if host_string.include?('@')
      userpass, hostname = host_string.split(/(.*)@(.*)$/)[1..2]
      username, password = userpass.split(/^(\w+):(.*)/)[1..2]
      
      # userpass split fails when no password is supplied but a user is
      # example: user@host.domain.tld
      # this will resplit userpass in this condition to take the username only
      username = userpass.split(/^(\w+):(.*)/)[0] if username.nil?
    else # !host.string.include?('@')
      hostname = host_string
    end # host_string.include?
    
    return filename ? filename : [hostname, username, password]
    
  end # def self.parse_host_string
  
  # Processes an array of host objects by calling the .config method on
  # each CR::Host object. 
  # 
  # It expects the method to retrieve the desired configuration as an array.
  # Then it compares it to what was previously saved to the repository 
  # (if it exists) then saves it if there was a change (of if it is a new file). 
  # Any new files will be added to the repository then committed at the end of 
  # this method.
  #
  def self.process(hosts, options)
    
    @@log.info "Opening repository: #{options[:repository]}"
    
    # initialize the repository
    repository = Repository.new(options[:repository], :git)
    
    hosts.each do |host|
      
      @@log.info "Processing: #{host.hostname}"
      
      begin
        
        current_config = host.process
      
      rescue SNMP::RequestTimeout
        
        @@log.error "SNMP timeout: #{host.hostname} -- skipping"
        next # hosts.each
        
      rescue Host::NonFatalError => e
        
        @@log.error "NonFatalError: #{host.hostname} - #{e} -- skipping"
        next # hosts.each
        
      end # begin
      
      if repository.read(host, options) != current_config
        
        repository.save(host, options, current_config)
        
      else # == current_config  
        
        @@log.debug "No change: #{host.hostname}"

      end # if
      
    end # hosts.each
    
    commit_message = "CR Commit: Processed #{hosts.size} host(s)"
    
    # add any new files and commit all changes
    repository.add_all
    repository.commit_all(commit_message)
    
    @@log.info "Processing complete"
    
  end # def self.process
  
  # Validates that a repository directory was specified on the command-line when
  # CR is ran as an application. The application will exit when missing.
  #
  def self.validate_repository(repository)
    
    if repository.nil?
      puts "missing repository"
      exit ARGUMENT_ERROR
    end
    
  end # self.validate_repository
  
end # module CR
