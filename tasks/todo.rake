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

desc 'Look for TODO and FIXME tags in the code'
task :todo do
  
  def egrep(pattern)
    
    Dir['**/*.rb'].each do |filename|
      
      # ignore todo/fixme comments in this file
      next if filename == 'Rakefile.rb' 
      
      count = 0
      
      open(filename) do |file|
        
        while line = file.gets
          
          count += 1
          
          if line =~ pattern
            puts "#{filename}:#{count}:#{line}"
          end # if
          
        end # while
        
      end # open
      
    end # Dir
    
  end # def egrep
  
  egrep /(FIXME|TODO|TBD)/
  
end # task :todo
