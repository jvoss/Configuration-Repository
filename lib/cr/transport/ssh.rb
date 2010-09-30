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

gem 'net-ssh', '>=2.0.23' # Require net-ssh version >=2.0.23

class CR
  
  module Transport
    
    class SSH
      
      # Initializes a new SSH object
      #
      def initialize(hostname, username, password)
        
        @hostname = hostname
        @username = username
        @password = password
        
      end # def initialize
      
      # Same as Net::SSH::Connection::Session.exec! 
      # If a block is not given, this will return all output (stdout and stderr)
      # as a single string.
      #
      def exec!(command, &block)
        
        response = []
          
        Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
          
          ssh.exec!(command.to_s, &block).each_line do |line|
           response.push(line)
          end # ssh.exec!
          
          ssh.loop
          
        end # Net::SSH.start
        
        return response
        
      end # def self.exec!
      
      # Opens an interactive shell on the remote device and yeilds
      #
      def open_channel_shell
        
        Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
            
          ssh.open_channel do |channel|
            
            channel.send_channel_request "shell" do |ch, success|
            
              yield ch, success
            
            end # channel.send_channel_request
            
            channel.wait
            
          end # ssh.open_channel
            
          ssh.loop
            
        end # Net::SSH.start          
        
      end # def open_channel_shell
      
    end # class SSH
    
  end # module Transport
  
end # class CR
