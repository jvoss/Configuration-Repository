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
