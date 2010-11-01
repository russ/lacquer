require "rubygems"
require "bundler/setup"

require "rake"
require "rake/rdoctask"
require "rspec"
require "rspec/core/rake_task"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "lacquer"
    gem.summary = %Q{Rails drop in for Varnish support.}
    gem.description = %Q{Rails drop in for Varnish support.}
    gem.email = "russ@bashme.org"
    gem.homepage = "http://github.com/russ/lacquer"
    gem.authors = ["Russ Smith (russ@bashme.org)", "Ryan Johns", "Garry Tan (garry@posterous.com), Gabe da Silveira (gabe@websaviour.com)"]
    gem.add_development_dependency "rspec", "~> 1.3.0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_path = "rspec"
  t.rspec_opts = %w[--color]
end

task :default => [ :spec ]

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "testing #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
