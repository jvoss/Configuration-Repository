# Copyright 2010 Andrew R. Greenwood and Jonathan P. Voss
#
# This file is part of Convene
#
# Convene is free software: you can redistribute it and/or modify it under 
# the terms of the GNU General Public License as published by the Free 
# Software Foundation, either version 3 of the License, or (at your option) 
# any later version.
#
# Convene is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License 
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with Convene. If not, see <http://www.gnu.org/licenses/>.
#

require 'convene/host'
require 'tmpdir'

module Convene
  
  TEST_OPTIONS = { :blacklist    => [],
                   :log          => nil,
                   :regex        => //,
                   :repository   => "#{Dir.tmpdir}/ConveneTest",
                   :username     => 'testuser',
                   :password     => 'testpass',
                   :snmp_options => { :Port      => Convene::Host::SNMP_DEFAULT_PORT,
                                      :Community => Convene::Host::SNMP_DEFAULT_COMMUNITY,
                                      :Version   => Convene::Host::SNMP_DEFAULT_VERSION,
                                      :Timeout   => Convene::Host::SNMP_DEFAULT_TIMEOUT,
                                      :Retries   => Convene::Host::SNMP_DEFAULT_RETRIES }   
                 }
  
  TEST_HOST_STRINGS = { 
    # hostname
    'host1.domain1.tld1'              => 
      { :hostname => 'host1.domain1.tld1', 
        :username => TEST_OPTIONS[:username],
        :password => TEST_OPTIONS[:password],
        :driver   => nil
      },
    # username/host                                       
    'convene://user2@host2.domain2.tld2' => 
      { :hostname => 'host2.domain2.tld2',
        :username => 'user2',
        :password => TEST_OPTIONS[:password],
        :driver   => nil
      },
    # username/password                                       
    'user3:pass3@host3.domain3.tld3'  => 
      { :hostname => 'host3.domain3.tld3',
        :username => 'user3',
        :password => 'pass3',
        :driver   => nil
      },
    # complex password                                       
    'user4:pa:s@s4@host4.domain4.tld4?driver=cisco' => 
      { :hostname => 'host4.domain4.tld4',
        :username => 'user4',
        :password => 'pa:s@s4',
        :driver   => 'cisco'
      },
    # complex password with uri and driver                                      
    'convene://user5:pa:s@s5@host5.domain5.tld5?driver=cisco' => 
      { :hostname => 'host5.domain5.tld5',
        :username => 'user5',
        :password => 'pa:s@s5',
        :driver   => 'cisco'
      }
  }
  
end # module Convene
