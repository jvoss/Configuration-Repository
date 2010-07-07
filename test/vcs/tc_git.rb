require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'fileutils'
require 'test/test_helpers'
require 'lib/vcs/git'

module CRTest
  
  class Test_git < Test::Unit::TestCase
    
    TEST_REPO  = TEST_OPTIONS[:repository]
    
    # test self.repo_exist? for invalid repositories
    #
    context "Checking to see if an invalid repository exists" do
      
      should "return false" do
        
        assert_equal false, CR::Repository::Git.exist?(TEST_REPO)
        
      end # should "return false"
      
    end # context "Checking to see if an invalid repository exists"
    
    # test self.init(repository) - creating repositories
    #
    context "Initializing a repository" do
      
      should "create a directory, intialize git, and return a git object" do
        
        obj = CR::Repository::Git.init(TEST_REPO)
        
        assert_kind_of CR::Repository::Git, obj
        
      end # should "create a directory and return a git object"
      
    end # context "Initializing a repository"
    
    # test self.repo_exist? for valid repositories
    #
    context "Checking to see if a valid repository exists" do
      
      should "return true" do
        
        assert CR::Repository::Git.exist?(TEST_REPO)
        
        FileUtils.rm_r(TEST_REPO) # remove testing directory
        
      end # should "return true"
      
    end # context "Checking to see if a valid repository exists"
    
  end # class Test_options

end # module CRTest