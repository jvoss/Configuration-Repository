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

require 'csv'
require 'uri'
require 'convene/constants'

module Convene
  
  module Parsing
  
    # Parses a CSV file and returns an array of host strings and options.
    # parse_file calls this method for handling CSV files. The fields are:
    # 
    # host_string,snmp_community,snmp_version,snmp_port,snmp_timeout,snmp_retries   
    #
    def parse_csv_file(filename, options)
      
      host_strings = []
      
      options = options.dup
      
      CSV.open(filename, 'r', ',') do |row|
            
        host_string = row[0]
            
        snmp_options = { :Community => row[1],
                         :Version   => SNMP_VERSION_MAP.invert[row[2]],
                         :Port      => row[3].to_i,
                         :Timeout   => row[4].to_i,
                         :Retries   => row[5].to_i }
                             
        options = options.merge(snmp_options)
      
        host_strings.push [host_string, options]
            
      end # CSV.open
      
      return host_strings
      
    end # def parse_csv_file
    
    # Parses filename and returns an array of Convene::Host objects. Files 
    # accepted are text files with each line containing a valid host string 
    # or a CSV in the following format:
    #
    # host_string,snmp_community,snmp_version,snmp_port,snmp_timeout,snmp_retries
    #
    # See parse_host_string for more information about host string formatting.
    #
    def parse_file(filename, options)
      
      host_strings = nil
        
        if File.extname(filename) == '.csv'
          
          host_strings = parse_csv_file(filename, options)
          
        else # != '.csv'
        
          options = {}
        
          host_strings = parse_txt_file(filename)
        
        end # if
        
      return host_strings
      
    end # def parse_file
    
    # Parses a host string into hostname, username, password and driver.
    # 
    # Valid host strings are in URI format:
    #   hostname.domain.tld
    #   hostname.domain.tld
    #   user@hostname.domain.tld
    #   user:pass@hostname.domain.tld
    #   user:pass@hostname.domain.tld?driver=cisco
    #   user:pass@hostname.domain.tld?driver=/path/to/driver
    #     .rb is assumed when specifying full driver path
    #
    # Domains can also be valid URIs: user:pass@domain.tld
    # URI's can include convene:// or be omitted
    #
    # Example:
    #   convene://user:pass@ciscodevice.domain.tld?driver=cisco
    #
    def parse_host_string(host_string, options)
      
      driver   = nil
      hostname = nil
      username = options[:username]
      password = options[:password]
      
      host_string, username, password = _validate_host_string(host_string, options)
      
      # Replace any '\' with '/' to match URI spec
      host_string = host_string.gsub('\\', '/')
      
      if host_string.match(/^((\w+):\/\/)/)
        raise ConveneError, "Unknown scheme #{$2}" unless $2 == 'convene'
      else
        host_string = "convene://#{host_string}"
      end # unless host_string.match
      
      uri = URI.parse(host_string)
   
      hostname = uri.host
      username = uri.user     unless uri.user.nil?
      password = uri.password unless uri.password.nil?
      
      driver = $1 if uri.query.to_s.match(/[d|D]river=(.*)/)
      
      attributes = { :hostname => hostname, 
                     :username => username, 
                     :password => password, 
                     :driver   => driver 
                   }
                   
      return attributes
      
    end # def parse_host_string  
    
    # Parses a txt file and returns an array of Convene::Host objects.
    # This method is called from parse_file when a txt file is supplied.
    #
    def parse_txt_file(filename)
      
      host_strings = []
        
      File.open(filename).each do |line|
        
        # ignore comment lines that start with '#'
        host_strings.push [ line.chomp, {} ] unless line =~ /^[#|\n]/
          
      end # File.open
      
      return host_strings
      
    end # def parse_txt_file
  
    private
    
    # Validate host string for complex passwords
    #
    def _validate_host_string(host_string, options)
      
      username = options[:username]
      password = options[:password]
      userpass = ''
      
      # host_string is frozen
      uri = host_string.dup
      
      # remove 'convene://'
      uri = uri.split(/convene:\/\/(.*)/)[1] if uri.include?('convene://')
      
      userpass = uri.split(/(.*)@.*$/)[1] if uri.include?('@')
        
      if userpass.match(/@/)
        uri.slice!("#{userpass}@") if uri.slice!("#{userpass}@")
        username, password = userpass.split(/^(\w+):(.*)/)[1..2]
      end # if userpass.include?
      
      return [uri, username, password]
      
    end # def _validate_host_string
  
  end # module Parsing
  
end # module Convene
