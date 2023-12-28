ENV['gem_push'] = 'no'

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Sm'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Push qg-sm-#{Qg::Sm::VERSION}.gem to Gemfury.com"
task :gemfury do
  package = "pkg/qg-sm-#{Qg::Sm::VERSION}.gem"
  if File.exist? package
    system "fury push #{package}"
  else
    STDERR.puts "E: gem `#{package}' not found."
    exit 1
  end
end

desc "Gemfury"
task :release do
  Rake::Task[:gemfury].invoke
end
APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'


load 'rails/tasks/statistics.rake'



Bundler::GemHelper.install_tasks

