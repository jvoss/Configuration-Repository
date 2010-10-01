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
require 'test/unit'
require 'shoulda'
require 'test/test_helpers'
require 'cr'

module CRTest

  class Test_cr < Test::Unit::TestCase
    
    # Test initialize #
    context "Creating a new instance" do
      
      should "raise if required options are missing" do
        
        assert_raise ArgumentError do 
          CR.new
        end
        
      end # should "raise if require options are missing"
      
      should "respond to attribute accessors and readers" do
        
        cr = CR.new(TEST_OPTIONS)
        
        assert_equal cr.username, TEST_OPTIONS[:username]
        assert_equal cr.password, TEST_OPTIONS[:password]
        
        assert_not_nil cr.blacklist
        assert_not_nil cr.hosts
        assert_not_nil cr.repository
        
        # Cleanup repository directory
        assert FileUtils.rm_r(TEST_OPTIONS[:repository])
        
      end # should "respond to attribute readers"
      
      should "allow either a blacklist file or array" do
        
        options = TEST_OPTIONS.dup
        
        options[:blacklist] = ['host.domain.tld']
        
        cr = CR.new(options)
        
        assert_equal cr.blacklist, options[:blacklist]
        
        options[:blacklist] = 'test/files/test_blacklist.txt'
        
        cr = CR.new(options)
        
        assert cr.blacklist.include?('hostA.domain.tld')
        assert cr.blacklist.include?('hostB.domain.tld')
        assert cr.blacklist.include?('hostC.domain.tld')
        
        # Cleanup repository directory
        assert FileUtils.rm_r(TEST_OPTIONS[:repository])
        
      end # should "allow either a blacklist file or array"
      
    end # context "Creating a new instance"
      
    context "Working with a CR object" do 
      
      # add_host
      should "allow host objects to be added" do
        
        cr = CR.new(TEST_OPTIONS)
        
        host = CR::Host.new('hostname', 'user', 'pass')
        
        assert_equal [host], cr.add_host(host)
        assert_equal [host], cr.hosts
        
      end # should "allow host objects to be added"
      
      # add_host_string
      should "allow hosts to be added by host string" do
        
        cr = CR.new(TEST_OPTIONS)
        
        cr.add_host_string('test.domain.tld')
        
        assert_equal 'test.domain.tld', cr.hosts.first.to_s
        
      end # should "allow hosts to be added by host string"
      
      # delete_host
      should "allow hosts to be deleted by string or object reference" do
        
        cr = CR.new(TEST_OPTIONS)
        
        cr.add_host_string('test.domain.tld')
        
        assert        cr.delete_host!('test.domain.tld')
        assert_equal  0, cr.hosts.size
        
      end # should "allow hosts to be deleted by string or object reference" do
      
      # import_blacklist
      # Tested during initialization when a file is supplied
      
      # import_file
      should "support importing CSV and TXT files of hosts" do
        
        cr = CR.new(TEST_OPTIONS)
        
        cr.import_file('test/files/test_csv.csv', :host)
        
        assert_equal cr.hosts.size, 1
        assert_equal cr.hosts.first.hostname, 'host.domain.tld'
        
        cr.import_file('test/files/test_txt.txt', :host)
        
        assert_equal cr.hosts.size, 5
        assert cr.hosts.include?('host1.domain1.tld1')
        assert cr.hosts.include?('host2.domain2.tld2')
        assert cr.hosts.include?('host3.domain3.tld3')
        assert cr.hosts.include?('host4.domain4.tld4')
        
        # Cleanup repository directory
        assert FileUtils.rm_r(TEST_OPTIONS[:repository])
        
      end # should "support import CSV and TXT files of hosts"
      
    end # context "Working with a CR object"
    
  end # class Test_cr

end # module CRTest