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

require 'rubygems'
require 'net/ssh'
require 'cr/host'

gem 'net-ssh', '>=2.0.23' # Require net-ssh version >=2.0.23

module CR
  
  class Host
    
    module Cisco
      
      # Error class for catching non-fatal SSH errors
      #
      class SSHError < RuntimeError; end
      
      # Retrieve a device's startup configuration as an array via SSH
      #
      def config
      
        startup_config = []
        
        begin
          
          Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
            
            ssh.exec!('show startup-config').each_line do |line|
             startup_config.push(line)
            end # ssh.exec!
            
            ssh.loop
            
          end # Net::SSH.start
          
        rescue => e
          
          case
          
            when e.to_s.include?('could not execute command:')
              raise Host::NonFatalError, e.to_s
          
            when e.is_a?(Net::SSH::AuthenticationFailed)
              raise Host::NonFatalError, "Authentication Failed"
              
            when e.is_a?(Errno::ECONNREFUSED)
              raise Host::NonFatalError, e.to_s
              
            else
              raise e
          
          end # case
          
        end # begin
        
        startup_config.shift until startup_config[0] =~ /^version/
        startup_config.unshift("!\r\n") # add back beginning '!' on configuration
        
        return {'startup_config' => startup_config}
        
      end # config

    end # module Cisco
    
  end # class Host
  
end # module CR
