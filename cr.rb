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
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
#

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