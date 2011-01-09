require 'lacquer'
require 'rails'
module Lacquer
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'lacquer/tasks.rb'
    end
  end
end