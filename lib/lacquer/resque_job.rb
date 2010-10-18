module Lacquer
  class ResqueJob
    @queue = :lacquer
  
    def self.perform(command)
      Varnish.new.purge(command)
    end
  end
end
