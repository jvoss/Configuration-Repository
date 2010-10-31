namespace :metrics do

  desc 'Generate CCN treemap'
  task :ccn_treemap do

    require 'saikuro_treemap'

    SaikuroTreemap.generate_treemap :code_dirs => ['lib']

  end # task :ccn_treemap

end # namespace :metrics 
