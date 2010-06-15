module Lacquer
  class DelayedJobJob < Struct.new(:command)
    def perform
      Varnish.new.purge(command)
    end
  end
end
