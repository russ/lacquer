module Lacquer
  class DelayedJobJob < Struct.new(:url)
    def perform
      Varnish.new.purge(url)
    end
  end
end
