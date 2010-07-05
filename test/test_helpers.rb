require 'lib/host'

module CRTest
  
  TEST_OPTIONS = { :log          => 'test.log',
                   :regex        => //,
                   :repository   => 'repo',
                   :username     => nil,
                   :password     => nil,
                   :snmp_options => { :Port      => CR::Host::SNMP_DEFAULT_PORT,
                                      :Community => CR::Host::SNMP_DEFAULT_COMMUNITY,
                                      :Version   => CR::Host::SNMP_DEFAULT_VERSION,
                                      :Timeout   => CR::Host::SNMP_DEFAULT_TIMEOUT,
                                      :Retries   => CR::Host::SNMP_DEFAULT_RETRIES }   
                  }
  
  TEST_HOST_STRINGS = { 
    # hostname
    'host1.domain1.tld1'              => 
      { :hostname => 'host1.domain1.tld1', 
        :username => TEST_OPTIONS[:username],
        :password => TEST_OPTIONS[:password] 
      },
    # username/host                                       
    'user2@host2.domain2.tld2'        => 
      { :hostname => 'host2.domain2.tld2',
        :username => 'user2',
        :password => TEST_OPTIONS[:password] 
      },
    # username/password                                       
    'user3:pass3@host3.domain3.tld3'  => 
      { :hostname => 'host3.domain3.tld3',
        :username => 'user3',
        :password => 'pass3' 
      },
    # complex password                                       
    'user4:pa:s@s4@host4.domain4.tld4' => 
      { :hostname => 'host4.domain4.tld4',
        :username => 'user4',
        :password => 'pa:s@s4' 
      }
  }
  
end # module CRTest