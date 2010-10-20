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

require 'ftools'
require 'logger'
require 'cr/rescue'
require 'cr/vcs/git'

class CR
  
  class Repository
    
    # Create a new repository object. VCS is the version control system 
    # to use, example :git
    #
    #==Example
    # Repository.new( :directory => '/path',
    #                 :regex     => //,
    #                 :type      => :git,
    #                 :username  => 'Username String',
    #                 :email     => 'email@string.org' )
    #    
    def initialize(options = {})
      
      @changed   = false
      
      @directory = options[:directory]
      @log       = options[:log]       || Logger.new(STDOUT)
      @regex     = options[:regex]
      @type      = options[:type]
      @username  = options[:username]  || 'Configuration Repository'
      @email     = options[:email]     || 'nobody@nowhere.com'
      
      _validate_repository(@directory)
      _initialize_vcs
      
    end # def initialize
    
    # Adds all files in the repository directory to tracking.
    #
    def add_all
      
      @repo.add('.')
      
    end # def add_all
    
    # Adds host directory in the repository to tracking.
    #
    def add_host(hostobj)
      
      @repo.add _directory(hostobj)
      
    end # def add_host(hostobj)
    
    # Indicates whether the repository has pending changes that need
    # committed.
    #
    def changed?
      @changed
    end # def changed?
    
    # Commits all files in the repository with the commit message applied
    # to the log.
    #
    def commit_all(message)
      
      @repo.commit_all(message.to_s)
      @changed = false
      
    end # def commit_all
    
    # Sets the repository's 'user.mail' attribute to the string supplied.
    #
    def config_user_email(newemail)
      @repo.config('user.email', newemail.to_s)
    end # def config_user_email
    
    # Sets the repository's 'user.name' attribute to the string supplied.
    #
    def config_user_name(newname)
      @repo.config('user.name', newname.to_s)
    end # def config_user_name
    
    # Checks to see if a repository exists at the directory specified 
    # during object creation.
    #
    def exist?
      
      Repository::const_get(@type.to_s.capitalize.to_sym).exist?(@directory)
      
    end # def exist?
    
    # Initializes a new empty repository in the directory specified during
    # CR::Repository initialization.
    #
    def init
      
      raise "Repository already initialized -- #{@directory}" if self.exist?
      
      @repo = @vcs.init(@directory)
      
      @changed = true
      
      config_user_name(@username)
      config_user_email(@email)
      
    end # def init
    
    # Opens the repository for operations.
    #
    def open
      
      log = @log.level == Logger::DEBUG ? @log : nil
      
      @repo = @vcs.open(@directory, :log => log)
      
    end # def open
    
    # Reads contents of hostObject.config from the repository into an array
    #
    def read(hostobj, filename)
      
      contents = []
      
      directory = _directory(hostobj)
      
      begin
        File.open("#{@directory}/#{directory}/#{filename}", 'r') do |file|
          file.each_line do |line|
            contents.push(line)
          end
        end # File.open
      rescue Errno::ENOENT # Catch missing files
        contents = []
      end
      
      return contents
      
    end # def read
    
    # Saves contents of CR::Host.config to directory named by the object's
    # hostname. #config should return a hash with key being a filename and 
    # value being an array containing the configuration.
    #
    def save(hostobj, contents)
      
      raise "Repository not initialized" unless self.exist?
      raise "Contents hash blank" if contents.nil?
      # FIXME Fix above raise statement to raise an exception that will not
      # cause the script to terminate but log through rescue.rb
      
      path = _directory(hostobj)
      
      contents.each_pair do |filename, value|
      
        if value.nil?
          
          @log.warn "Empty from device: #{hostobj.hostname} - #{filename}"
          next # filename, value
          
        end # if value.nil?
      
        if read(hostobj, filename) == value
          
          @log.debug "No change: #{hostobj.hostname} - #{filename}"
          next # filename, value
          
        end # if read(hostobj, options, filename) == value
        
        @log.debug "Saving: #{hostobj.hostname} - #{filename}"
        
        # Save the file to disk
        @changed = true if _save_file("#{path}/#{filename}", value)
      
      end # contents.each_pair
      
    end # def save
    
    # Observer method for receiving updates when configurations are
    # pulled from hosts.
    #
    def update(hostobj, config)
      save(hostobj, config)
      add_host(hostobj)
    end # def update
    
    private
    
    # Determins directory within repository for CR:Host object to save files.
    # Return a string: 'host/path/host.domain.tld/'
    #
    def _directory(hostobj)
      
      path = hostobj.hostname.match(@regex).captures
      
      path.push hostobj.hostname
      
      path.join('/') + '/'
      
    end # def _directory
    
    # Initializes the repository object into instance variable @repo
    #
    def _initialize_vcs
      
      case @type
        when :git then @vcs = Git
        else
          raise ArgumentError, "VCS unsupported -- #{@type}"
      end # case
      
      # Open the repository if it exists or initialize a new one
      exist? ? open : init
      
    end # _initialize_vcs
    
    # Saves contents array to filename. Top level directory being repository 
    # directory is assumed. Filename can be string like: 'hostname/etc/somefile'
    # This will be interpreted as: repo_directory + 'hostname/etc/somefile'
    #
    def _save_file(filename, contents)
      
      # Make any needed subdirectories
      sub_dir  = filename.split('/')
      filename = sub_dir.pop          # last entry is filename
      sub_dir  = sub_dir.join('/')
      
      File.makedirs("#{@directory}/#{sub_dir}")
      
      file = File.open("#{@directory}/#{sub_dir}/#{filename}", 'w')
      
      contents.each do |line|
        file.syswrite line
      end # contents.each
    
      file.close
      
      @log.debug "Saved #{sub_dir}/#{filename}: #{contents.size} lines"
      
      return true
       
    end # def _save_file
    
    def _validate_repository(repository)
    
      if repository.nil?
        raise ArgumentError, 'missing repository directory'
      end
    
    end # _validate_repository
    
  end # class Repository

end # class CR
