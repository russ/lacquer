require 'lacquer'
require 'rails'
module Lacquer
  class Railtie < Rails::Railtie
    rake_tasks do
      
      desc "hello"
      taks :lacquer do
      end
      
      raise "FAIL #{__FILE__}"
      
      load 'lacquer/tasks.rb'
    end
  end
end