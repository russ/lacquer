module Lacquer
  class ResqueJob
    @queue = :lacquer

    def self.perform(urls)
      Varnish.new.purge(*urls)
    end
  end
end
