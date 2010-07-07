require 'ftools'
require 'lib/vcs/git'

module CR
  
  # TODO Reconsider how this class works to be able to support multiple VCS's
  
  class Repository
    
    # Create a new repository object
    # VCS is the versioning system to use, example :git
    #    
    def initialize(directory, type)
      
      @directory = directory
      @type      = type
      
      _initialize_vcs
      
    end # def initialize
    
    # Adds all files in the repository directory to the repository
    #
    def add_all
      
      @repo.add('.')
      
    end # def add_all
    
    # Commits all files in the repository
    #
    def commit_all(message)
      
      @repo.commit_all(message.to_s)
      
    end # def commit_all
    
    # Checks to see if a repository exists at the directory 
    # specified during object creation
    #
    def exist?
      
      Repository::const_get(@type.to_s.capitalize.to_sym).exist?(@directory)
      
    end # def exist?
    
    # Initializes a new empty repository
    #
    def init
      
      raise "Repository already initialized -- #{@directory}" if self.exist?
     
      @repo = @vcs.init(@directory)
      
      # TODO Allow options to change these settings:
      @repo.config('user.name', 'Configuration Repository')
      
    end # def init
    
    # Opens the repository
    #
    def open
     
      # TODO Add logging support with Git here
      @repo = @vcs.open(@directory)
      
    end # def open
    
    # Reads contents of a file from the repository directory into an array
    # TODO Consider moving file operations to another class
    #
    def read(filename)
      
      contents = []
      
      File.open("#{@directory}/#{filename}", 'r') do |file|
        file.each_line do |line|
          contents.push(line)
        end
      end # File.open
      
      return contents
      
    end # def read
    
    # Saves contents to a file to the repository
    # TODO Consider moving file operations to another class
    #
    def save(filename, contents)
      
      raise "Repository not initialized" unless self.exist?
      
      # TODO Clean up finding the filename vs directory
      directory = filename.to_s.split('/')
      directory.pop
      directory.join('/')
      
      # Make directories if they do not exist
      File.makedirs("#{@directory}/#{directory}")
      
      file = File.open("#{@directory}/#{filename}", 'w')
    
      contents.each do |line|
        file.print line
      end # contents.each
      
    end # def save
    
    private
    
    # Initializes the repository object into instance variable @repo
    #
    def _initialize_vcs
      
      case @type
        when :git then @vcs = Git
        else
          raise ArgumentError, "VCS unsupported -- #{@type}"
      end # case
      
      # Open the repository if it exists
      open if exist? 
      
    end # _initialize_vcs
    
  end # class Repository
  
end # module CR