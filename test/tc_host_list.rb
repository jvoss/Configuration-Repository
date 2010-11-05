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

require 'test/unit'
require 'test/test_helpers'
require 'cr/host_list'

module CRTest

  class Test_host_list < Test::Unit::TestCase
    
    def setup
      
      @host_list = ::CR::HostList.new
      
      @array = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
      
      @array.each {|l| @host_list << l}
      
    end # def setup
    
    def test_brackets
      4.times do 
        index = rand(@host_list.size - 1)
        
        assert_equal @array[index], @host_list[index]
        assert_equal @array[index + 1], @host_list.next
      end # 4.times
    end # test_brackets
    
    def test_first
      assert_equal @array.first, @host_list.first
      
      next_index = @array.index(@array.first) + 1
      
      assert_equal nil, @host_list.prev
      assert_equal @array[next_index], @host_list.next
    end # def test_first
    
    def test_each
      @host_list.each_index do |x|
        assert_equal @array[x], @host_list[x]
      end # @host_list.each
    end # def test_each
    
    def test_last
      assert_equal @array.last, @host_list.last
      
      prev_index = @array.index(@array.last) - 1
      
      assert_equal @array[prev_index], @host_list.prev
      assert_equal @array[prev_index + 1], @host_list.next
      assert_equal nil, @host_list.next
    end # def test_last
    
    def test_next
      assert_equal @array[1], @host_list.next
      
      index = 4
      
      @host_list[4]
      assert_equal @array[index + 1], @host_list.next
      
      index = @host_list.index(@host_list.first)
      assert_equal @array[index + 1], @host_list.next
    end # def test_next
    
    def test_prev
      assert_equal nil, @host_list.prev
      
      index = 4
      
      @host_list[index]
      assert_equal @array[index - 1], @host_list.prev
      
      index = @host_list.index(@host_list.last)
      assert_equal @array[index - 1], @host_list.prev
    end # def test_prev
    
    def test_rewind
      @host_list[4]
      @host_list.rewind
      
      assert_equal 0, @host_list.instance_variable_get(:@position)
    end # def test_rewind
    
  end # class Test_host_list
  
end # module CRTest
