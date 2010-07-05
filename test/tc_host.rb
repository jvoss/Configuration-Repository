require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'test/test_helpers'
require 'lib/host'

module CRTest
  
  class Test_host < Test::Unit::TestCase
    
    TEST_HOST         = 'host.domain.tld'
    TEST_USER         = 'username'
    TEST_PASS         = 'p@$$word'
    TEST_SNMP_OPTIONS = CRTest::TEST_OPTIONS[:snmp_options]
    
    ## helper methods ##
    
    def assert_host_attributes(host_obj, attributes)
      
      obj_hostname     = host_obj.instance_variable_get(:@hostname)
      obj_username     = host_obj.instance_variable_get(:@username)
      obj_password     = host_obj.instance_variable_get(:@password)
      obj_snmp_options = host_obj.instance_variable_get(:@snmp_options)
      
      assert_equal attributes[:hostname],     obj_hostname
      assert_equal attributes[:username],     obj_username
      assert_equal attributes[:password],     obj_password
      assert_equal attributes[:snmp_options], obj_snmp_options
      
    end # def assert_host_attributes
    
    ## end helper methods ##
    
    # test initialize(hostname, username, password, snmp_options = {})
    #
    context "Initializing a host object" do
      
      should "return a host object with the default SNMP options" do
        
        exp_snmp_options = TEST_OPTIONS[:snmp_options]
        exp_snmp_options[:Host] = TEST_HOST
                             
        exp_attributes   = { :hostname     => TEST_HOST, 
                             :username     => TEST_USER,
                             :password     => TEST_PASS,
                             :snmp_options => exp_snmp_options }
                             
        host = CR::Host.new(TEST_HOST, TEST_USER, TEST_PASS)
        
        assert_host_attributes(host, exp_attributes)
        
      end # should "return a host object with the proper attributes"
      
      should "return a host with custom SNMP options if supplied" do
      
        snmp_options   =   { :Port      => 1200,
                             :Community => 'coMMunity',
                             :Version   => :SNMPv1,
                             :Timeout   => 400,
                             :Retries   => 50, 
                             :Host      => TEST_HOST }
                             
        exp_attributes =   { :hostname     => TEST_HOST, 
                             :username     => TEST_USER,
                             :password     => TEST_PASS,
                             :snmp_options => snmp_options }
                             
        host = CR::Host.new(TEST_HOST, TEST_USER, TEST_PASS, snmp_options)
                             
        assert_host_attributes(host, exp_attributes)
        
      end # should "return a host with custom SNMP options if supplied"
      
    end # context "Initalizing a host object"
    
    # TODO test config method on Host
    
  end # class Test_host
  
end # module CRTest