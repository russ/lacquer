require 'capistrano/version'

if defined?(Capistrano::VERSION) && Gem::Version.new(Capistrano::VERSION).release >= Gem::Version.new('3.0.0')
  load File.expand_path("../capistrano/v3/tasks/lacquer.rake", __FILE__)
else
  require 'lacquer/capistrano/v2/hooks'
end
