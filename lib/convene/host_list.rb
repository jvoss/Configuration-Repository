# Copyright 2010 Andrew R. Greenwood and Jonathan P. Voss
#
# This file is part of Convene
#
# Convene is free software: you can redistribute it and/or modify it under 
# the terms of the GNU General Public License as published by the Free 
# Software Foundation, either version 3 of the License, or (at your option) 
# any later version.
#
# Convene is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License 
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with Convene. If not, see <http://www.gnu.org/licenses/>.
#

module Convene

  class HostList < Array

    def initialize(*args)

      @position = 0

      super(*args)

    end # def initialize

    def [](*args)

      p1 = args[0] # index, start, or range 
      p2 = args[1] # length

      @position = p2.nil? ? ( p1.kind_of?(Range) ? p1.last   \
                                                 : p1      ) \
                          : args.sum

      super(*args)

    end # def []

    def first(n = nil)

      @position = n.nil? ? 0     \
                         : n - 1 

      n.nil? ? super()  \
             : super(n)

    end # def first
       
    def each

      for @position in @position...self.size do

        yield self[@position]

      end # for

    end # def each

    def last(n = nil)

      @position = n.nil? ? self.index( super() )        \
                         : self.index( super(n).first )

      n.nil? ? super()  \
             : super(n)

    end # def last

    def next

      @position += 1 unless @position >= self.size

      self[@position]

    end # def next

    def prev

      @position -= 1 if @position > 0

      @position != 0 ? self.fetch(@position) \
                     : nil

    end # def last

    # Resets the host list position to 0, the beginning of the list.
    #
    def rewind

      @position = 0

    end # def rewind

  end # class HostList

end # module Convene
