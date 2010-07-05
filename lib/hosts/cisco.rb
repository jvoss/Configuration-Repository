require 'net/ssh' # TODO require SSH library >= 2.0.23
require 'lib/host'

module CR
  
  class Host
    
    module Cisco
      
      # Retrieve a device's startup configuration as an array via SSH
      #
      def config
      
        startup_config = []
        
        Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
          ssh.exec!('show startup-config').each_line do |line|
           startup_config.push(line)
          end
          
          ssh.loop
        end
        
        startup_config.shift until startup_config[0] =~ /^version/
        startup_config.unshift("!\r\n") # add back beginning '!' on configuration
        
        return startup_config
        
      end # config
      
    end # module Cisco
    
  end # class Host
  
end # module CR