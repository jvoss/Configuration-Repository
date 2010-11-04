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

class CR

  class HostList < Array

    def initialize(*args)
      @position = 0
      super(*args)
    end # def initialize
    
    def [](*idx)
      @position = idx[1].nil? ? ( idx[0].kind_of?(Range) ? idx[0].last : idx[0] ) \
                              : idx.sum
      super *idx
    end # def [](idx)
    
    def first(n = nil)
      @position = n.nil? ? 0 : self.index(self[n - 1])
      n.nil? ? super() : super(n)
    end # def first
       
    def each
      while @position < self.size
        yield self[@position]
        @position += 1
      end
    end # def each
    
    def last(n = nil)
      @position = n.nil? ? self.index(super()) : self.index(super(n).first)
      n.nil? ? super() : super(n)
    end # def last
    
    def next
      @position += 1 unless @position >= self.size
      self[@position]
    end # def next
    
    def prev
      object = nil
      
      previous_position = @position
      
      @position -= 1 if @position > 0
      object = self.fetch(@position) unless previous_position == 0
      
      return object
    end # def last
    
    # Resets the host list position to 0, the beginning of the list.
    #
    def reset
      @position = 0
    end # def resets
    
  end # class HostList
  
end # class CR
