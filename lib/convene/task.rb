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

require 'logger'
require 'convene/transport/scp'
require 'convene/transport/ssh'
require 'convene/transport/telnet'

module Convene

  class Task
    
    include Comparable
    
    attr_reader :name, :snmp, :objectives
    
    def initialize(name, snmp, objectives)
      @name       = name
      @objectives = objectives
      @snmp       = snmp
    end # def initialize
    
    def ==(task)
      
      @name == task.to_s
      
    end # def ==
    
    def run(hostname, username, password, log = Logger.new(nil))
      
      @log = log
      
      file_output = {}
      
      @objectives.each_pair do |name, attrib|
        
        @log.debug "Running objective: #{name}"
        
        case attrib['transport']
          
          when 'scp'
            contents = _scp(hostname, username, password, attrib['file-list'])
            file_output.merge!(contents)
          
          when 'ssh'
            filename = attrib['filename']
            
            contents = _ssh(hostname, username, password, attrib['commands'])
            file_output[filename] = _format(attrib['format'], contents)
        
          when 'telnet'
            raise ConveneError, "SCP not implimented with Tasks system yet"
          
        end # case attrib['transport']
        
      end # @objectives.each_pair
      
      return file_output
      
    end # def run

    def to_s
      
      @name
      
    end # def to_s
    
    private
    
    def _format(format, contents)
      
      return contents if format.nil?
      
      format.each do |eval_string|
        
        eval(eval_string)
        
      end # format.each
      
      return contents
      
    end # def _format
    
    def _scp(host, user, pass, filelist)
      
      output = {}
      
      scp = Transport::SCP.new(host, user, pass)
      
      filelist.each do |filename|
      
        @log.debug "SCP Download: #{filename}"
      
        output[filename] = scp.download!(filename)
      
      end # filelist.each
      
      return output
      
    end # def _scp
    
    def _ssh(host, user, pass, commands)
      
      output = nil
      
      ssh = Transport::SSH.new(host, user, pass)
      
      if commands.size == 1
        
        @log.debug "SSH: #{commands[0]}"
                
        output = ssh.exec!(commands[0])
        
      else
      
        output = []
      
        ssh.open_channel_shell do |ch, data|
        
          ch.on_data do |ch, data|
          
            lines = data.split(/\r\n|\n/)
            
            lines.each do |line|
              output.push(line)      
            end # lines.each
          
            ch.close # if exit_sent == true 
          
          end # ch.on_data
        
          commands.each do |command|
            @log.debug "SSH: #{command}"
            ch.send_data(command + "\n")
          end # commands.each
        
        end # ssh.open_channel_shell
      
        #raise Convene::ConveneError, "multiple SSH commands not implimented"
      
        output = nil if output.empty?
      
      end # if commands.size
      
      return output
      
    end # def _ssh
    
  end # class Task
  
end # module Convene
