require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'test/test_helpers'
require 'lib/options'

module CRTest
  
  class Test_options < Test::Unit::TestCase
    
    TEST_LOG   = TEST_OPTIONS[:log]
    TEST_REPO  = TEST_OPTIONS[:repository]
    TEST_REGEX = TEST_OPTIONS[:regex]
    
    # test initialize(log, repository, regex = //)
    #
    context "Initializing a options object" do
      
      should "return an object if valid options were supplied" do
        
        obj = CR::Options.new(TEST_LOG, TEST_REPO, TEST_REGEX)
        
        assert_equal TEST_LOG,    obj.log
        assert_equal TEST_REPO,   obj.repository
        assert_equal TEST_REGEX,  obj.regex
        
        assert_kind_of CR::Options, obj
        assert_kind_of Regexp,      obj.regex
        
      end # should "return an object if valid options were supplied"
      
      should "have STDOUT as log if nil was supplied" do
        
        assert_equal :STDOUT, CR::Options.new(nil, TEST_REPO, TEST_REGEX).log
        
      end # should "raise have STDOUT as log if nil was supplied"
      
      should "raise if a repository was not supplied" do
        
        assert_raise CR::Options::ArgumentError do
          CR::Options.new(TEST_LOG, nil, TEST_REGEX)
        end
        
      end # should "raise if a repository was not supplied"
      
      should "raise if an invalid regular expression was supplied" do
        
        assert_raise CR::Options::ArgumentError do
          CR::Options.new(TEST_LOG, TEST_REPO, 'testing')
        end
        
      end # should "raise if an invalid regular expression was supplied"
      
    end # context "Initializing a options object"
    
  end # class Test_options

end # module CRTest