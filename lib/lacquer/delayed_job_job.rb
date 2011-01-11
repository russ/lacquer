module Lacquer
  class DelayedJobJob < Struct.new(:urls)
    def perform
      Varnish.new.purge(*urls)
    end
  end
end
