module Lacquer
  class Configuration
    OPTIONS = [ :varnish_servers ]

    # Enable cache
    attr_accessor :enable_cache

    # Varnish servers
    attr_accessor :varnish_servers

    # Application default ttl
    attr_accessor :default_ttl

    # Application default ttl
    attr_accessor :retries

    # Job Backend
    attr_accessor :job_backend
    
    # Error handler
    attr_accessor :command_error_handler

    def initialize
      @enable_cache = true
      @varnish_servers = []
      @default_ttl = 1.week
      @job_backend = :none
      @retries = 5
      @command_error_handler = nil
    end

    # Returns a hash of all configurable options
    def to_hash
      OPTIONS.inject({}) do |hash, option|
        hash.merge(option.to_sym => send(option))
      end
    end
  end
end
