begin

  require 'jeweler'

  Jeweler::Tasks.new do |s|

    s.name          = 'CR'
    s.summary       = 'Archive network device configuration into version control'
    s.email         = 'jvoss@onvox.net'
    s.homepage      = 'http://github.com/jvoss/Configuration-Repository'
    s.description   = 'Simplify managing device configuration backups in version control'
    s.authors       = ['Andrew R. Greenwood', 'Jonathan P. Voss']
    s.files         =  FileList['[A-Z]*', '{lib,test}/**/*', '.gitignore']

    s.add_dependency 'dnsruby'
    s.add_dependency 'git'
    s.add_dependency 'net-scp'
    s.add_dependency 'net-ssh', '>= 2.0.23'
    s.add_dependency 'rake'
    s.add_dependency 'saikuro_treemap'
    s.add_dependency 'snmp'

  end # Jeweler::Tasks.new do |s|

rescue LoadError

  puts 'Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com'

end # begin
