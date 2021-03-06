($:.unshift File.expand_path(File.join( File.dirname(__FILE__), 'lib' ))).uniq!
require 'slack'

# =======================
# = Gem packaging tasks =
# =======================
begin
  require 'echoe'
  
  task :install => :'package:install'
  task :package => :'package:package'
  task :manifest => :'package:manifest'
  namespace :package do
    Echoe.new('slack', Slack::Version) do |g|
      g.project = 'speck'
      g.author = ['elliottcable']
      g.email = ['Slack@elliottcable.com']
      g.summary = "Magic makes everybody's life a little easier, no?"
      g.url = 'http://github.com/elliottcable/Slack'
      g.runtime_dependencies = ['speck']
      g.development_dependencies = ['echoe >= 3.0.2', 'speck', 'yard', 'maruku']
      g.manifest_name = '.manifest'
      g.retain_gemspec = true
      g.rakefile_name = 'Rakefile.rb'
      g.ignore_pattern = /^\.git\/|^meta\/|\.gemspec/
    end
  end
  
rescue LoadError
  desc 'You need the `echoe` gem to package Slack'
  task :package
end

# ===============
# = Speck tasks =
# ===============
begin
  require 'speck'
  require 'slack'
  require 'spark'
  require 'spark/rake/speck_task'
  
  task :default => :'speck:run'
  task :speck => :'speck:run'
  namespace :speck do
    Spark::Rake::SpeckTask.new
  end
  
rescue LoadError
  desc 'You need the `speck`, `slack`, and `spark` gems to run specks'
  task :speck
end

# =======================
# = Documentation tasks =
# =======================
begin
  require 'yard'
  require 'yard/rake/yardoc_task'
  
  task :documentation => :'documentation:generate'
  namespace :documentation do
    YARD::Rake::YardocTask.new :generate do |t|
      t.files   = ['lib/**/*.rb']
      t.options = ['--output-dir', File.join('meta', 'documentation'),
                   '--readme', 'README.markdown',
                   '--markup', 'markdown', '--markup-provider', 'maruku']
    end
    
    task :open do
      system 'open ' + File.join('meta', 'documentation', 'index.html') if RUBY_PLATFORM['darwin']
    end
  end
  
rescue LoadError
  desc 'You need the `yard` and `maruku` gems to generate documentation'
  task :documentation
end

desc 'Check everything over before commiting'
task :aok => [:'documentation:generate', :'documentation:open',
              :'package:manifest', :'package:package',
              :'speck:run']

task :ci => [:'documentation:generate', :'speck:run']
