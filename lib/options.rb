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

module CR
  
  class Options
    
    class ArgumentError < StandardError; end
    
    attr_reader :log, :regex, :repository
    
    def initialize(log, repository, regex = //)

      @log        = log
      @regex      = regex
      @repository = repository
      
      _validate_log
      _validate_regex
      _validate_repository
    
    end # def initialize

    private
    
    def _validate_log
      
      @log ||= :STDOUT
      
    end # def _validate_log
    
    def _validate_regex
      
      msg = "Invalid Regular Expression -- #{@regex}"
      raise ArgumentError, msg, caller unless @regex.is_a?(Regexp)
      
    end # def _validate_regex
    
    def _validate_repository
      
      raise ArgumentError if @repository.nil?
      
    end # def _validate_repository
    
  end # class Options
  
end # module CR