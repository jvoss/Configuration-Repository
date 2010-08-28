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
require "logger"
require 'optparse'
require 'rubygems'
require 'cr/constants'
require 'cr/dns'
require 'cr/host'
require 'cr/options'
require 'cr/repository'

module CR
  
  VERSION = '0.1.0'
  
  # Default logging configuration
  @@log                 = Logger.new(STDOUT)
  @@log.level           = Logger::INFO
  @@log.datetime_format = "%Y-%m-%d %H:%M:%S"
  
  # Parses command-line options using OptionParser and returns an array of
  # host objects and an options hash used throughout CR.
  #
  # ===Command line options:
  #   Usage: cr.rb -r REPOSITORY [OPTIONS]
  #     -b, --blacklist FILENAME         
  #     -d, --domain DOMAIN              Domain or file:<filename> (can be multiple)
  #     -l, --logfile FILENAME           Log output file
  #     -n, --hostname HOSTNAME          Hostname or file:<filename> (can be multiple)
  #     -r, --repository REPOSITORY      Repository directory
  #     -x, --regex REGEX                Regular expression
  #     -u, --username USERNAME          Default device username
  #     -p, --password PASSWORD          Default device password
  #         --verbosity LEVEL            Verbose level [fatal|error|warn|info|debug]
  #
  #     SNMP Options:
  #         --snmp-community COMMUNITY   Community string (default: public)
  #         --snmp-port PORT             Port (default: 161)
  #         --snmp-retries VALUE         Retries (default: 2)
  #         --snmp-timeout VALUE         Timeout in seconds (default: 3)
  #         --snmp-version VERSION       Version (default: 2c)
  #
  #     Other:
  #     -h, --help                       Show this message
  #     -v, --version                    Show version
  #
  # ===Examples
  #
  # Run against a single host:
  #     cr.rb -r /path/to/repository -n host.domain.tld -u username -p password 
  #
  # Run against multiple hosts with the same credentials:
  #     cr.rb -r /path/to/repository -n host.domain.tld -n host.domain.tld
  #       -u username -p password
  #
  # Run against domains with different credentials:
  #     cr.rb -r /path/to/repository -d user1:pass1@domain1.tld
  #       -d user2:pass2@domain2.tld
  # 
  # Run against a txt file of host strings containing hosts:
  #     cr.rb -r /path/to/repository -n file:hostfile.txt -u user -p pass
  #
  # Run against a CSV file of host strings containing domains:
  #     cr.rb -r /path/to/repository -d file:domainfile.csv -u user -p pass
  #
  # Usernames and passwords can also be specified as part of the host string
  # within either file type allowing for greater flexiblility in environments
  # with varying credentials.
  #
  def self.parse_cmdline
    
    options = {}
    options[:blacklist]    = []
    options[:domain]       = []
    options[:host]         = []
#    options[:log]          = nil # TODO - remove - no longer needed
    options[:regex]        = //
    options[:username]     = nil
    options[:password]     = nil
    options[:snmp_options] = {}
    
    begin
      
      OptionParser.new do |opts|
        
        opts.banner = "Usage: #{File.basename($0)} -r REPOSITORY [OPTIONS]"
        
        opts.on('-b', '--blacklist FILENAME', 'File containing blacklisted hosts') do |b|
          options[:blacklist] = parse_blacklist(b)
        end
        
        opts.on('-d', '--domain DOMAIN', 'Domain or file:<filename> (can be multiple)') do |d|
          options[:domain].push(d)
        end # opts.on
        
        opts.on("-l", '--logfile FILENAME', "Log output file") do |l|
#          options[:log] = l
          @@log = Logger.new(l.to_s)
        end # opts.on
        
        opts.on('-n', '--hostname HOSTNAME', "Hostname or file:<filename> (can be multiple)") do |h|
          options[:host].push(h)
        end # opts.on
        
        opts.on('-r', '--repository REPOSITORY', 'Repository directory') do |r|
          options[:repository] = r
        end # opts.on
        
        opts.on('-x', '--regex REGEX', Regexp, 'Regular expression') do |regex|
          options[:regex] = regex
        end # opts.on
        
        opts.on('-u', '--username USERNAME', 'Default device username') do |u|
          options[:username] = u
        end # opts.on
        
        opts.on('-p', '--password PASSWORD', 'Default device password') do |p|
          options[:password] = p
        end # opts.on
        
        opts.on('--verbosity LEVEL', 'Verbose level [fatal|error|warn|info|debug]') do |verbose|
          # TODO deal with verbosity level in log
          case verbose
            when 'fatal'
              @@log.level = Logger::FATAL
            when 'error'
              @@log.level = Logger::ERROR
            when 'warn'
              @@log.level = Logger::WARN
            when 'info'
              @@log.level = Logger::INFO
            when 'debug'
              @@log.level = Logger::DEBUG
            else
              puts "Unsupported verbose level -- #{verbose}"
              exit ARGUMENT_ERROR
          end
        end # opts.on
        
        opts.separator ""
        opts.separator "SNMP Options:"
        
        description = "Community string (default: #{Host::SNMP_DEFAULT_COMMUNITY})"
        opts.on('--snmp-community COMMUNITY', description) do |com|
          options[:snmp_options][:Community] = com
        end # opts.on
        
        description = "Port (default: #{Host::SNMP_DEFAULT_PORT})"
        opts.on('--snmp-port PORT', Integer, description) do |port|
          options[:snmp_options][:Port] = port
        end # opts.on
        
        description = "Retries (default: #{Host::SNMP_DEFAULT_RETRIES})"
        opts.on('--snmp-retries VALUE', Integer, description) do |retries|
          options[:snmp_options][:Retries] = retries
        end # opts.on
        
        description = "Timeout in seconds (default: #{Host::SNMP_DEFAULT_TIMEOUT})"
        opts.on('--snmp-timeout VALUE', Integer, description) do |timeout|
          options[:snmp_options][:Timeout] = timeout
        end # opts.on
        
        description = "Version (default: #{SNMP_VERSION_MAP[Host::SNMP_DEFAULT_VERSION]})"
        opts.on('--snmp-version VERSION', String, description) do |version|
          
          x = SNMP_VERSION_MAP.invert[version]
          
          if x.nil?
            puts "Unsupported SNMP version -- #{version}"
            exit ARGUMENT_ERROR
          end
          
          options[:snmp_options][:Version] = x
        end # opts.on
        
        opts.separator ""
        opts.separator "Other:"
        
        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit NONFATAL_ERROR
        end # opts.on_tail
        
        opts.on_tail('-v', '--version', 'Show version') do
          puts VERSION
          exit NONFATAL_ERROR
        end
        
      end.parse! # OptionParser.new
      
      validate_repository(options[:repository])
      
    rescue OptionParser::InvalidOption => e
      
      puts e
      exit ARGUMENT_ERROR
      
    rescue OptionParser::MissingArgument => e
      
      puts e
      exit ARGUMENT_ERROR
      
    end # begin
    
    # TODO fix this
    hosts = create_hosts(options[:host], options, :host)
    hosts = hosts + create_hosts(options[:domain], options, :domain)
    
#    options = CR::Options.new(options[:log], options[:repository], options[:regex])
    return hosts, options
    
  end # def self.parse_cmdline
  
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
    
    hosts = []
    
    host_objects = []
    
    host_strings.each do |host|
        
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
  
  # Provides access to Logger. 
  #
  # By default Logger is initialized to direct messages to STDOUT with a
  # level set to INFO. Command line options are also available to customize
  # logging information at runtime.
  #
  def self.log
    
    @@log
    
  end # def self.log
  
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
        
        # FIXME use CSV library for parsing CSV files
        File.open(filename).each do |line|
          values = line.chomp.split(',')
          
          host_string = values[0]
          
          snmp_options = { :Community => values[1],
                           :Version   => SNMP_VERSION_MAP.invert[values[2]],
                           :Port      => values[3].to_i,
                           :Timeout   => values[4].to_i,
                           :Retries   => values[5].to_i }
                           
          options[:snmp_options] = options[:snmp_options].merge(snmp_options)
          
          host_strings.push(host_string)
        end
        
      else
      
        File.open(filename).each do |line|
          # ignore comment lines that start with '#'
          host_strings.push(line.chomp) unless line =~ /^[#|\n]/
        end
      
      end # if File.extname(filename)
      
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
      
    end # if host.string.include('file:')
    
    if host_string.include?('@')
      userpass, hostname = host_string.split(/(.*)@(.*)$/)[1..2]
      username, password = userpass.split(/^(\w+):(.*)/)[1..2]
      
      # userpass split fails when no password is supplied but a user is
      # example: user@host.domain.tld
      # this will resplit userpass in this condition to take the username only
      username = userpass.split(/^(\w+):(.*)/)[0] if username.nil?
    else
      hostname = host_string
    end # host_string.include?('@')
    
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
        next
        
      rescue Host::NonFatalError
        
        @@log.error "NonFatalError: #{host.hostname} -- skipping"
        next
        
      end
      
      if repository.read(host, options) != current_config
        
        repository.save(host, options, current_config)
#        @@log.debug "Saving: #{host.hostname}"
        
      else  
        
        @@log.debug "No change: #{host.hostname}"
      end
      
      
    end # hosts.each
    
    commit_message = "CR Commit: Processed #{hosts.size} hosts."
    
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