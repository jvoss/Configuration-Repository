# Copyright 2010 Matthew J. Kosmoski
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
require 'net/telnet'
require 'cr/host'

#gem 'net-ssh', '>=2.0.23' # Require net-ssh version >=2.0.23

module CR
  
  class Host
    
    module ExtremeXOS
      
      # Retrieve a device's startup configuration as an array via Telnet
      #
      def config
      
        startup_config = []
        startup_config_tmp = ""
        
        begin

          telnet = Net::Telnet::new("Host" => @hostname)
          telnet.login(@username, @password)
          telnet.cmd('disable clipaging')
          telnet.cmd('show config') do |line|
            startup_config.push(line)
          end
 
        rescue # TODO  figure out how to catch more specific RuntimeErrors from SSH
          # catches stuff like:
          # /usr/lib/ruby/gems/1.8/gems/net-ssh-2.0.23/lib/net/ssh/connection/session.rb:322:in `exec': 
          # could not execute command: "show startup-config" (RuntimeError)
          # from /usr/lib/ruby/gems/1.8/gems/net-ssh-2.0.23/lib/net/ssh/connection/channel.rb:597:in `call'
          
          raise Host::NonFatalError
         
        end # begin

         startup_config_tmp.gsub!(/\* \w+\.\d+ \#/, "")
         startup_config_tmp = startup_config.join
         startup_config = startup_config_tmp.split(//)

        return startup_config
        
      end # config
      
      # Error class for catching non-fatal SSH errors
      #
      class SSHError < RuntimeError; end
      
    end # module Cisco
    
  end # class Host
  
end # module CR
