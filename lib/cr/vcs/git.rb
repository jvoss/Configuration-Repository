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
require 'git'
require 'logger'

module CR
  
  class Repository
  
    class Git < Git::Base 
  
      # Initializes a new Git repository. If the directory does not exist
      # it will be created. git_options hash is passed through to the 
      # Git::Base library.
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
      
      # Commits all files in the repository and adds the message string 
      # supplied to the log.
      #
      def commit_all(message)
        
        begin
          super message
        rescue ::Git::GitExecuteError
          # TODO provide some useful information about why commit was not needed
          # stub - catches when a commit is not necessary (need to confirm that
          # it will still catch other errors
          CR.log.debug "no commit needed -- skipped"
        end
        
      end # self.commit_all
  
      # Checks to see if a valid repository exists
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