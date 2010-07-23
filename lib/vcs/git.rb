require 'rubygems'
require 'git'
require 'logger'

module CR
  
  class Repository
  
    class Git < Git::Base 
  
      # Initialize repository
      #
      def self.init(repository, git_options = {})
        
        raise "Repository already exists -- #{repository}" \
          if self.exist?(repository)
        
        begin
          
          Dir.chdir(repository)
        
        rescue Errno::ENOENT # directory does not exist
        
          Dir.mkdir(repository)
          Dir.chdir(repository)
        
        end # begin
      
        super '.', git_options
        
      end # def self.init
      
      def commit_all(message)
        
        begin
          super message
        rescue ::Git::GitExecuteError
          # TODO provide some useful information about why commit was not needed
          # stub - catches when a commit is not necessary
        end
        
      end # self.commit_all
  
      # Check to see if a valid repository exists
      #
      def self.exist?(repository)
        
        begin 
          
          # Do not log this Git open, every check would log 'Starting Git'
          return true if self.open(repository, :log => Logger.new(nil))
          
        rescue ArgumentError
        
          return false
          
        end # begin
        
      end # def exist?
      
    end # class Git
    
  end # class Repository
  
end # module CR