require 'bundler/gem_tasks'
require 'rake'
require 'rspec/core/rake_task'

namespace :spec do
  RSpec::Core::RakeTask.new(:normal) do |t|
    t.pattern ='spec/**/*_spec.rb'
    t.rcov = false
  end
end

desc "RSpec tests"
task "spec" => "spec:normal"

task "default" => "spec"
