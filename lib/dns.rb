require 'net/dns/resolver'
require 'net/dns/rr/srv'

module CR
  
  module DNS
    
    # Return an array of hostnames from an AXFR request for a domain
    def self.axfr(domain)
      hosts = []
      
      resolver = Net::DNS::Resolver.new
#      resolver.logger = CR.log
      
      resolver.axfr(domain.to_s).answer.each do |record|
        next unless record.is_a?(Net::DNS::RR::A) or record.is_a?(Net::DNS::RR::AAAA)
        hosts.push record.name.chop # chop removes trailing period from answer
      end
      
      return hosts
    end # def self.axfr
    
  end # module DNS
  
end # module CR