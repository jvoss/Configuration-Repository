require 'optparse'
require 'rubygems'
require 'lib/constants'
require 'lib/dns'
require 'lib/host'
require 'lib/options'

module CR
  
  VERSION = '1.0.0'
  
  def self.parse_cmdline
    
    options = {}
#    options[:blacklist]    = []
    options[:domain]       = []
    options[:host]         = []
    options[:log]          = nil
    options[:regex]        = //
    options[:username]     = nil
    options[:password]     = nil
    options[:snmp_options] = {}
    
    begin
      
      OptionParser.new do |opts|
        
        opts.banner = "Usage: cr.rb -r REPOSITORY [OPTIONS]"
        
#        opts.on('-b', '--blacklist ', 'Blacklist file') do |b|
#          options[:blacklist] = parse_blacklist(b)
#        end
        
        opts.on('-d', '--domain DOMAIN', 'Domain or file:<filename> (can be multiple)') do |d|
          options[:domain].push(d)
        end # opts.on
        
        opts.on("-l", '--logfile FILENAME', "Log output file") do |l|
          options[:log] = l
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
    
    options = CR::Options.new(options[:log], options[:repository], options[:regex])
    return hosts, options
    
  end # def self.parse_cmdline
  
  # TODO refactor
  def self.create_hosts(host_strings, options, type)
    
    hosts = []
    
    host_strings.each do |host|
      
      if type == :domain
        
        x = parse_host_string(host, options)
        
        if x.is_a?(Array)
        
          domain, username, password = parse_host_string(host, options)
        
          DNS.axfr(domain).each do |hostname|
            hosts.push CR::Host.new(hostname, username, password, options[:snmp_options])
          end
        
        else
          
          hosts = parse_file(x, options, :domain)
        
        end # if x.is_a?(Array)
      
      else
      
        x = parse_host_string(host, options)
        
        if x.is_a?(Array)
          hostname, username, password = x[0], x[1], x[2]
           
          hosts.push CR::Host.new(hostname, username, password, options[:snmp_options])
        else
          
          hosts = parse_file(x, options, :host)
        
        end
      
      end # if type == :domain
      
    end # host_strings.each
    
    return hosts
    
  end # def self.create_hosts
    
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
  
  def self.process(hosts, options)
    # stub
  end # def self.process
  
  def self.validate_repository(repository)
    
    if repository.nil?
      puts "missing repository"
      exit ARGUMENT_ERROR
    end
    
  end # self.validate_repository
  
end # module CR