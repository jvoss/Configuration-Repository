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

require 'test/unit'
require 'test/test_helpers'
require 'snmp'
require 'convene/host'
require 'convene/rescue'

module ConveneTest 
  
  class Test_resuce < Test::Unit::TestCase
    
    def test_catch_fatal
      
      assert_raises SystemExit do
        
        begin
          raise 'Test Rescue'
        rescue => e
          ::Convene::Rescue.catch_fatal(e)
        end
        
      end # asser_raises SystemExit
      
    end # def test_catch_fatal
    
    def test_catch_host
      
      host = ::Convene::Host.new( :hostname => 'testhost', 
                                  :log => Logger.new(nil)
                                )
      
      error_object = nil
      
      # Catching host errors should log but not terminate the script
      assert_nothing_raised do
      
        begin
          raise ::Convene::HostError, 'NonFatal'
        rescue => error_object
          
          ::Convene::Rescue.catch_host(error_object, host)
          
        end # begin
      
      end # assert_nothing_raised
      
      assert error_object.is_a?(::Convene::HostError)
      
      error_object = nil
      
      # Catching SNMP timeouts should log but not terminate the script
      assert_nothing_raised do
        
        begin
          raise SNMP::RequestTimeout, 'SNMP Timeout'
        rescue => error_object
          
          assert error_object.is_a?(SNMP::RequestTimeout)
          
          ::Convene::Rescue.catch_host(error_object, host)
          
        end # begin
        
      end # assert_nothing_raised
      
      assert error_object.is_a?(SNMP::RequestTimeout)
      
    end # def test_catch_host
    
  end # class Test_rescue
  
end # module ConveneTest