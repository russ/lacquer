module Lacquer
  class ResqueJob
    @queue = :lacquer
  
    def self.perform(command)
      VarnishInterface.new.purge(command)
    end
  end
end
