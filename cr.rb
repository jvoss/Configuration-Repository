require 'lib/core'

require 'pp'

# Gather a list of hosts
#hosts = ConfigRepo.gather_hosts()

# Iterate through the hosts

  # Check if the host matches a regular expression - parse

  # Check if a host is in a blacklist - parse
  
  # SSH to host and dump its configuration - process
  
  # Check the configuration against a copy saved to the repository - process
  
    # If it is different, save it to disk - process
    
  # Add any new files to the repository - process
  
  # Commit all changes to the repository - process

#options = { #:domain     => 'tcom.purdue.edu',
#            :hostfile   => 'hosts.txt',
#            :host_regex => /^(\w+)-/,
#            :directory  => 'testing',
#            :username   => 'archive',
#            :password   => 'acc597',
#            :logfile    => 'log/configrepo.log' }
#            
#
#
#options = ConfigRepo::Options.new( :domain     => 'tcom.purdue.edu', # or array of domains
#                                   :hostfile   => 'hosts.txt', # or an array of hostfiles
#                                   :regex      => /^(\w+)/, 
#                                   :repository => 'repo',
#                                   :username   => 'archive',
#                                   :password   => 'acc597',
#                                   :log        => 'cr.log' )

#options, hosts = CR.parse_cmdline         
hosts, options = CR.parse_cmdline

CR.process(hosts, options)

#pp hosts
#pp options

#hosts.each do |host|
#  pp host.config
#end

#ConfigRepo.process(hosts, options)