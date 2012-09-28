module Lacquer
  class Configuration
    OPTIONS = []

    # Enable cache
    attr_accessor :enable_cache

    # Varnish servers
    attr_accessor :varnish_servers

    # Application default ttl
    attr_accessor :default_ttl

    # Number of retries before failing
    attr_accessor :retries

    # Job backend
    attr_accessor :job_backend

    # Error handler
    attr_accessor :command_error_handler

    # Purge Command
    attr_accessor :purge_command

    # Pass Command (in vcl_fetch)
    attr_accessor :pass_command

    # Use sudo for start up
    attr_accessor :use_sudo

    def initialize
      @enable_cache = true
      @varnish_servers = []
      @default_ttl = 0
      @job_backend = :none
      @retries = 5
      @command_error_handler = nil
      @purge_command = "url.purge"
      @pass_command = "pass"
      @use_sudo = false
    end

    # Returns a hash of all configurable options
    def to_hash
      OPTIONS.inject({}) do |hash, option|
        hash.merge(option.to_sym => send(option))
      end
    end
  end
end
