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

begin

  require 'jeweler'

  Jeweler::Tasks.new do |s|

    s.name          = 'convene'
    s.summary       = 'Archive network device configuration into version control'
    s.email         = 'jvoss@onvox.net'
    s.homepage      = 'http://github.com/jvoss/convene'
    s.description   = 'Simplify managing device configuration backups in version control'
    s.authors       = ['Andrew R. Greenwood', 'Jonathan P. Voss']
    s.files         =  FileList['[A-Z]*', '{lib,test}/**/*', '.gitignore']

    s.add_dependency 'dnsruby'
    s.add_dependency 'git'
    s.add_dependency 'net-scp'
    s.add_dependency 'net-ssh', '>= 2.0.23'
    s.add_dependency 'rake'
    s.add_dependency 'snmp'

  end # Jeweler::Tasks.new do |s|

rescue LoadError

  puts 'Jeweler, or one of its dependencies, is not available.'
  puts 'Install it with: gem install technicalpickles-jeweler -s http://gems.github.com'

end # begin
