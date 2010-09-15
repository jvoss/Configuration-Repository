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
require 'cr/rescue'
require 'cr/vcs/git'

module CR
  
  class Repository
    
    # Create a new repository object. VCS is the version control system 
    # to use, example :git
    #    
    def initialize(directory, type)
      
      @directory = directory
      @type      = type
      
      _initialize_vcs
      
    end # def initialize
    
    # Adds all files in the repository directory to tracking.
    #
    def add_all
      
      @repo.add('.')
      
    end # def add_all
    
    # Commits all files in the repository with the commit message applied
    # to the log.
    #
    def commit_all(message)
      
      @repo.commit_all(message.to_s)
      
    end # def commit_all
    
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
      
      #raise "Repository already initialized -- #{@directory}" if self.exist?
      
      @repo = @vcs.init(@directory)
      
      # TODO Allow options to change these settings:
      @repo.config('user.name', 'Configuration Repository')
      @repo.config('user.email', 'nobody@nowhere.com')
      
    end # def init
    
    # Opens the repository for operations.
    #
    def open
      
      log = CR.log.level == Logger::DEBUG ? CR.log : nil
      
      @repo = @vcs.open(@directory, :log => log)
      
    end # def open
    
    # Reads contents of hostObject.config from the repository into an array
    #
    def read(hostobj, options, filename)
      
      contents = []
      
      directory = _directory(hostobj, options)
      
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
    
    # Saves contents of CR::Host.config to file named by the object's
    # hostname.
    #
    def save(hostobj, options, contents)
      
      raise "Repository not initialized" unless self.exist?
      
      if contents.nil?
      
        CR.log.warn "No configuration found for #{hostobj.hostname}"
      
      else
        
        path = _directory(hostobj, options)
        
        # Make directories if they do not exist
        File.makedirs("#{@directory}/#{path}")
        
        contents.each_pair do |filename, value|
        
          if value.nil?
            CR.log.warn "Empty on device: #{hostobj.hostname} - #{filename}"
            next
          end
        
          if read(hostobj, options, filename) == value
            CR.log.debug "No change: #{hostobj.hostname} - #{filename}"
            next
          end
          
          CR.log.debug "Saving: #{hostobj.hostname} - #{filename}"
          
          # Make any needed subdirectories
          sub_dir  = filename.split('/')
          filename = sub_dir.pop          # last entry is filename
          sub_dir  = sub_dir.join('/')
          
          File.makedirs("#{@directory}/#{path}/#{sub_dir}")
          
          file = File.open("#{@directory}/#{path}/#{sub_dir}/#{filename}", 'w')
          
          value.each do |line|
            file.syswrite line
          end # contents.each
        
        end # contents.each_pair
        
      end # contents.nil?
      
    end # def save
    
    private
    
    # Determins directory within repository for CR:Host object to save files.
    # Return a string: 'host/path/host.domain.tld/'
    #
    def _directory(hostobj, options)
      
      path = hostobj.hostname.match(options[:regex]).captures
      
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
    
    # Determines what the repository internal path structure and file name 
    # should be based off the regex option. Returns as an array.
    #
    def _filename(hostobj, options)
      
      path = hostobj.hostname.match(options[:regex]).captures
      
      path.push hostobj.hostname
      
    end # def _filename
    
  end # class Repository
  
  # Processes an array of host objects by calling the .config method on
  # each CR::Host object. 
  # 
  # It expects the method to retrieve the desired configuration as an array.
  # Then it compares it to what was previously saved to the repository 
  # (if it exists) then saves it if there was a change (of if it is a new file). 
  # Any new files will be added to the repository then committed at the end of 
  # this method.
  #
  def self.process(hosts, options)
    
    log.info "Opening repository: #{options[:repository]}"
    
    # initialize the repository
    repository = Repository.new(options[:repository], :git)
    
    hosts.each do |host|
      
      log.info "Processing: #{host.hostname}"
        
      repository.save(host, options, process_host(host))
      
    end # hosts.each
    
    commit_message = "CR Commit: Processed #{hosts.size} host(s)"
    
    # add any new files and commit all changes
    repository.add_all
    repository.commit_all(commit_message)
    
    log.info "Processing complete"
    
  end # def self.process
  
  # Returns CR::Host object's configuration.
  # This method is typically called from process
  #
  #---
  #TODO: Rename process_host method?
  #+++
  #
  def self.process_host(host_object)
    
    current_config = []
    
    begin
    
      current_config = host_object.process
       
    rescue => e
      
      CR::Rescue.catch_host(e, host_object)

    end # begin
    
    return current_config
    
  end # def self.process_host
  
  # Validates that a repository directory was specified on the command-line when
  # CR is ran as an application. The application will exit when missing.
  #
  def self.validate_repository(repository)
    
    if repository.nil?
      raise ArgumentError, 'missing repository'
    end
    
  end # self.validate_repository

end # module CR
