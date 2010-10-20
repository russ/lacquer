module Lacquer
  class ResqueJob
    @queue = :lacquer

    def self.perform(url)
      Varnish.new.purge(url)
    end
  end
end
