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

require 'optparse'
require 'convene/rescue'

module Convene
  
  module CLI
  
    # Parses command-line options using OptionParser and returns an array of
    # host objects and an options hash used throughout CR.
    #
    # ===Command line options:
    #  Usage: convene.rb -r REPOSITORY [OPTIONS]
    #    -b, --blacklist FILENAME         File containing blacklisted hosts
    #    -d, --domain DOMAIN              Domain name (can be multiple)
    #    -D, --domain-file FILENAME       Filename of domain URIs
    #    -l, --logfile FILENAME           Log output file
    #    -n, --hostname HOSTNAME          Hostname (can be multiple)
    #    -N, --hostname-file FILENAME     Filename of hostname URIs
    #    -r, --repository REPOSITORY      Repository directory
    #    -x, --regex REGEX                Regular expression
    #    -u, --username USERNAME          Default device username
    #    -p, --password PASSWORD          Default device password
    #        --verbosity LEVEL            Verbose level [fatal|error|warn|info|debug]
    #
    #
    #    SNMP Options:
    #            --snmp-community COMMUNITY   Community string (default: public)
    #            --snmp-port PORT             Port (default: 161)
    #            --snmp-retries VALUE         Retries (default: 2)
    #            --snmp-timeout VALUE         Timeout in seconds (default: 3)
    #            --snmp-version VERSION       Version (default: 2c)
    #
    #    Other:
    #    -h, --help                       Show this message
    #    -v, --version                    Show version
    #
    # ===Examples
    #
    # Run against a single host:
    #     convene.rb -r /path/to/repository -n host.domain.tld -u username -p password 
    #
    # Run against multiple hosts with the same credentials:
    #     convene.rb -r /path/to/repository -n host.domain.tld -n host.domain.tld
    #       -u username -p password
    #
    # Run against domains with different credentials:
    #     convene.rb -r /path/to/repository -d user1:pass1@domain1.tld
    #       -d user2:pass2@domain2.tld
    # 
    # Run against a txt file of host strings containing hosts:
    #     convene.rb -r /path/to/repository -N hostfile.txt -u user -p pass
    #
    # Run against a CSV file of host strings containing domains:
    #     convene.rb -r /path/to/repository -D domainfile.csv -u user -p pass
    #
    # Usernames and passwords can also be specified as part of the host string
    # within either file type allowing for greater flexiblility in environments
    # with varying credentials.
    #
    def self.parse_cmdline(argv)
      
      options = {}
      options[:blacklist]    = []
      options[:domain]       = []
      options[:domain_files] = []
      options[:host]         = []
      options[:host_files]   = []
      options[:log]          = nil
      options[:regex]        = //
      options[:username]     = nil
      options[:password]     = nil
      options[:snmp_options] = {}
      
      begin
        
        opt = OptionParser.new do |opts|
          
          opts.banner = "Usage: #{File.basename($0)} -r REPOSITORY [OPTIONS]"
          
          opts.on('-b', '--blacklist FILENAME', 'File containing blacklisted hosts') do |b|
            options[:blacklist] = b
          end # opts.on
          
          opts.on('-d', '--domain DOMAIN', 'Domain name (can be multiple)') do |d|
            options[:domain].push(d)
          end # opts.on
          
          opts.on('-D', '--domain-file FILENAME', String, 'Filename of domain URIs') do |file|
            options[:domain_files].push(file)
          end # opts.on
          
          opts.on("-l", '--logfile FILENAME', "Log output file") do |l|
            options[:log] = Logger.new(l.to_s)
            options[:log].datetime_format = "%Y-%m-%d %H:%M:%S"
          end # opts.on
          
          opts.on('-n', '--hostname HOSTNAME', "Hostname (can be multiple)") do |h|
            options[:host].push(h)
          end # opts.on
          
          opts.on('-N', '--hostname-file FILENAME', String, 'Filename of hostname URIs') do |file|
            options[:host_files].push(file)  
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
            unless options[:log]
              options[:log] = Logger.new(STDOUT)
              options[:log].datetime_format = "Convene>"
            end
                        
            case verbose
              when 'fatal'
                options[:log].level = Logger::FATAL
              when 'error'
                options[:log].level = Logger::ERROR
              when 'warn'
                options[:log].level = Logger::WARN
              when 'info'
                options[:log].level = Logger::INFO
              when 'debug'
                options[:log].level = Logger::DEBUG
              else
                raise ArgumentError, "Unsupported verbose level -- #{verbose}"
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
              raise ArgumentError, "Unsupported SNMP version -- #{version}"
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
          end # opts.on_tail
          
        end # OptionParser.new
        
        opt.parse!(argv)
        
        convene = Convene::Manager.new(options)
        
        options[:host].each do |host_string|
          convene.add_host_string(host_string)
        end # options[:host].each
        
        options[:host_files].each do |filename|
          convene.import_file(filename, :host)
        end # options[:host_files].each
        
        options[:domain].each do |host_string|
          convene.add_host_string(host_string, :domain)
        end # options[:domain].each
        
        options[:domain_files].each do |filename|
          convene.import_file(filename, :domain)
        end # options[:domain_files]
        
        # Catch errors when dealing with command line options so that clean
        # error reporting can be done
        # 
        rescue => e
        
          Convene::Rescue.catch_fatal(e)
        
      end # begin
      
      return convene
      
    end # def self.parse_cmdline
  
  end # module CLI
  
end # module Convene
