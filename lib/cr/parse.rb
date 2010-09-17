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

require 'csv'
require 'cr/constants'
require 'cr/host'
require 'cr/log'
require 'cr/rescue'

module CR
  
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
  
  # Parses a CSV file and returns an array of CR::Host objects. 
  # parse_file calls this method for handling CSV files. The fields are:
  # 
  # host_string,snmp_community,snmp_version,snmp_port,snmp_timeout,snmp_retries   
  #
  def self.parse_csv_file(filename, options, type)
    
    host_objects = []
    
    options = options.dup
    
    CSV.open(filename, 'r', ',') do |row|
          
      host_string = row[0]
          
      snmp_options = { :Community => row[1],
                       :Version   => SNMP_VERSION_MAP.invert[row[2]],
                       :Port      => row[3].to_i,
                       :Timeout   => row[4].to_i,
                       :Retries   => row[5].to_i }
                           
      options[:snmp_options] = options[:snmp_options].merge(snmp_options)
      
      host_objects += create_hosts(host_string, options, type)
          
    end # CSV.open
    
    return host_objects
    
  end # def self.parse_csv_file
  
  # Parses a domain and returns an array of CR::Host objects.
  #
  def self.parse_domain(domain, options)
    
    host_strings = []
    
    DNS.axfr(domain).each do |hostname|
      
      host_strings.push(hostname)
          
    end # DNS.axfr
    
    return create_hosts(host_strings, options, :host)
    
  end # def self.parse_domain
  
  # Parses filename and returns an array of CR::Host objects. Files accepted
  # are text files with each line containing a valid host string or a CSV
  # in the following format:
  #
  # host_string,snmp_community,snmp_version,snmp_port,snmp_timeout,snmp_retries
  #
  # See parse_host_string for more information about host string formatting.
  #
  def self.parse_file(filename, options, type)
    
    host_objects = []
      
      if File.extname(filename) == '.csv'
        
        host_objects += parse_csv_file(filename, options, type)
        
      else # != '.csv'
      
        host_objects += parse_txt_file(filename, options, type)
      
      end # if
      
    return host_objects
    
  end # def self.parse_file
  
  # Parses a host string into hostname, username, password and driver.
  # 
  # Valid host strings are:
  #   hostname.domain.tld
  #   user@hostname.domain.tld
  #   user:pass@hostname.domain.tld
  #   user:pass@hostname.domain.tld=Driver
  #
  # Domains can also be valid host strings: user:pass@domain.tld
  #
  # Example:
  #   user:pass@ciscodevice.domain.tld=Cisco
  #
  def self.parse_host_string(host_string, options)
    
    driver   = nil
    hostname = nil
    username = options[:username]
    password = options[:password]
    
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
    
    if hostname.include?('=')
      hostname, driver = hostname.split(/(.*)=(.*)$/)[1..2]
      driver = eval('CR::Host::' + driver)
    end # if hostname.include?('=')
    
    return [hostname, username, password, driver]
    
  end # def self.parse_host_string  
  
  # Parses a txt file and returns an array of CR::Host objects.
  # This method is called from parse_file when a txt file is supplied.
  #
  def self.parse_txt_file(filename, options, type)
    
    host_objects = []
    host_strings = []
    
    options = options.dup
      
    File.open(filename).each do |line|
      
      # ignore comment lines that start with '#'
      host_strings.push(line.chomp) unless line =~ /^[#|\n]/
        
    end # File.open
    
    host_objects = create_hosts(host_strings, options, type)      
    
    return host_objects
    
  end # def self.parse_txt_file
  
end # module CR
