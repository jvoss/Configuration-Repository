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

require 'net/ssh'
require 'cr/host'

gem 'net-ssh', '>=2.0.23' # Require net-ssh version >=2.0.23

module CR
  
  class Host
    
    module Foundry
      
      # Retrieve a device's startup configuration as an array via SSH
      #
      def config
        
        CR::log.debug "Loaded Foundry driver"
      
        running_config = []
        
        begin
          
          Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
            
            ssh.open_channel do |channel|
              
              channel.send_channel_request "shell" do |ch, success|
              
                ch.on_data do |ch, data|
                
                  lines = data.split("\r\n")
                
                  lines.each do |line|
                    running_config.push(line+"\r\n")
                  end # lines.each
                  
                  # Match when to close the channel:
                  # Just after the configuration is printed to the screen there
                  # is a blank like containing "\r\n" and is the only occurance
                  # when running this command.
                  ch.close if data.to_s.match(/^\r\n$/)
                
                end # ch.on_data
              
                CR::log.debug "Sending command 'terminal length 0'"
                ch.send_data("terminal length 0\n")
                
                CR::log.debug "Sending command 'show running-config'"
                ch.send_data("show running-config\n")
              
              end # ssh.open_channel
              
              channel.wait
              
            end # ssh.open_channel
            
            ssh.loop
            
          end # Net::SSH.start          
          
        rescue # TODO  figure out how to catch more specific RuntimeErrors from SSH
          # catches stuff like:
          # /usr/lib/ruby/gems/1.8/gems/net-ssh-2.0.23/lib/net/ssh/connection/session.rb:322:in `exec': 
          # could not execute command: "show startup-config" (RuntimeError)
          # from /usr/lib/ruby/gems/1.8/gems/net-ssh-2.0.23/lib/net/ssh/connection/channel.rb:597:in `call'
          
          raise Host::NonFatalError
          
        end # begin       

        CR::log.debug "Parsing configuration file"        

        # Shift out MOTD and other output messages until the configuration starts
        running_config.shift until running_config[0] =~ /^!/ or running_config.empty?

        # Pop off trailing output until the end of the configuration where 'end' is seen
        running_config.pop until running_config.last =~ /^end\r\n$/ or running_config.empty?
        
        # TODO Raise if running_config.empty? this would indicate there was a terrible
        # failure stepping through the session.
        
        return running_config
        
      end # config
      
      # Error class for catching non-fatal SSH errors
      #
      class SSHError < RuntimeError; end
      
    end # module Foundry
    
  end # class Host
  
end # module CR