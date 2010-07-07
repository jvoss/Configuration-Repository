require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'fileutils'
require 'test/test_helpers'
require 'lib/repository'

module CRTest
  
  # FIXME This test needs severely overhauled
  
  class Test_repository < Test::Unit::TestCase
    
    TEST_REPO  = TEST_OPTIONS[:repository]
    TEST_VCS   = [:git]
    
    TEST_VCS.each do |vcs|
    
      context "Checking a repository" do
        
        setup do
          
          @repo = CR::Repository.new(TEST_REPO, vcs)
          
        end # setup
        
        teardown do
          
          FileUtils.rm_r(TEST_REPO) # remove testing directory
          
        end # teardown
        
        should "return false if it does not exist" do
          
          assert_equal false, @repo.exist?
          
          @repo.init # init the test directory so that it can be delete at teardown
          
        end # should "return false"
        
        should "initialize a new repository if one does not exist" do
          
          assert @repo.init
          
        end # should "initialize a new repository if one does not exist"
        
        should "return true if it does exist" do
          
          @repo.init
          
          assert @repo.exist?
          
        end # should "return true if it does exist"
        
        should "allow saving to a file" do
          
          @repo.init
          
          assert @repo.save('testfile', 'TEST SAVE')
          
        end # should "allow saving to a file"
        
        should "allow reading from a file" do
          
          @repo.init
          
          File.open("#{TEST_REPO}/testfile", 'w') do |file|
            file.print "TEST SAVE"
          end # File.open
          
          assert @repo.read('testfile').include?('TEST SAVE')
          
        end # should "allow reading from a file"
        
        should "allow adding all files to a repository" do
          
          @repo.init
          @repo.save('testfile', 'TEST SAVE')
          
          assert @repo.add_all
          
        end # should "allow adding all files to a repository" do
          
        should "allow committing all files in a repository" do
          
          @repo.init
          @repo.save('testfile', 'TEST SAVE')
          @repo.add_all
          
          assert @repo.commit_all('TEST COMMIT')
          
        end # should "allow committing all files in a repository"
        
      end # context "Checking a repository"
    
    end # TEST_VCS.each
    
  end # class Test_repository
  
end # module CRTest