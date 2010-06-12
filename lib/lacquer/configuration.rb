module Lacquer
  class Configuration
    OPTIONS = [ :varnish_servers ]

    # Varnish servers
    attr_accessor :varnish_servers

    def initialize
      @varnish_servers = []
    end

    # Returns a hash of all configurable options
    def to_hash
      OPTIONS.inject({}) do |hash, option|
        hash.merge(option.to_sym => send(option))
      end
    end
  end
end
