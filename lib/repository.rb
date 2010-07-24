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
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
#

require 'ftools'
require 'lib/vcs/git'

module CR
  
  class Repository
    
    # Create a new repository object
    # VCS is the version control system to use, example :git
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
      
#      raise "Repository already initialized -- #{@directory}" if self.exist?
     
      @repo = @vcs.init(@directory)
      
      # TODO Allow options to change these settings:
      @repo.config('user.name', 'Configuration Repository')
      @repo.config('user.email', 'nobody@nowhere.com')
      
    end # def init
    
    # Opens the repository
    #
    def open
     
      # TODO Add logging support with Git here
      @repo = @vcs.open(@directory)
      
    end # def open
    
    # Reads contents of hostObject.config from the repository into an array
    #
    def read(hostobj, options)
      
      contents = []
      
      filename = _filename(hostobj, options).join('/')
      
      begin
        File.open("#{@directory}/#{filename}", 'r') do |file|
          file.each_line do |line|
            contents.push(line)
          end
        end # File.open
      rescue Errno::ENOENT # Catch missing files
        contents = []
      end
      
      return contents
      
    end # def read
    
    # Saves contents to a file to the repository
    #
    def save(hostobj, options)
      
      raise "Repository not initialized" unless self.exist?
      
      path     = _filename(hostobj, options)
      sub_dir  = path[0...-1].join('/') if path.size > 1
      filename = path.pop
      
      # Make directories if they do not exist
      File.makedirs("#{@directory}/#{sub_dir}") unless sub_dir.nil?
      
      file = File.open("#{@directory}/#{sub_dir}/#{filename}", 'w')
    
      hostobj.config.each do |line|
        file.syswrite line
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
      
      # Open the repository if it exists or initialize a new one
      if exist?
        open
      else
        init
      end
      
    end # _initialize_vcs
    
    # Determines what the repository internal path structure and file name 
    # should be based off the regex option. Returns as an array.
    #
    def _filename(hostobj, options)
      
      path = hostobj.hostname.match(options[:regex]).captures
      path.push hostobj.hostname
      
    end # def _filename
    
  end # class Repository
  
end # module CR