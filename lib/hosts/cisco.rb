require 'rubygems'
require 'net/ssh'
require 'lib/host'

gem 'net-ssh', '>=2.0.23' # Require net-ssh version >=2.0.23

module CR
  
  class Host
    
    module Cisco
      
      # Retrieve a device's startup configuration as an array via SSH
      #
      def config
      
        startup_config = []
        
        begin
          Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
            ssh.exec!('show startup-config').each_line do |line|
             startup_config.push(line)
            end
            
            ssh.loop
          end
        rescue # TODO  figure out how to catch more specific RuntimeErrors from SSH
          # catches stuff like:
          # /usr/lib/ruby/gems/1.8/gems/net-ssh-2.0.23/lib/net/ssh/connection/session.rb:322:in `exec': 
          # could not execute command: "show startup-config" (RuntimeError)
          # from /usr/lib/ruby/gems/1.8/gems/net-ssh-2.0.23/lib/net/ssh/connection/channel.rb:597:in `call'
        end
        
        startup_config.shift until startup_config[0] =~ /^version/
        startup_config.unshift("!\r\n") # add back beginning '!' on configuration
        
        return startup_config
        
      end # config
      
    end # module Cisco
    
  end # class Host
  
end # module CR