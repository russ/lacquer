Lacquer.configure do |config|
  # Globally enable/disable cache
  config.enable_cache = true

  # Unless overridden in a controller or action, the default will be used
  config.default_ttl = 1.week

  # Can be :none, :delayed_job, :resque
  config.job_backend = :none

  # Array of Varnish servers to manage
  config.varnish_servers << {
    :host => "0.0.0.0", :port => 6082 # if you have authentication enabled, add :secret => "your secret"
  }

  # Number of retries
  config.retries = 5

  # Config handler (optional, if you use Hoptoad or another error tracking service)
  config.command_error_handler = lambda { |s| HoptoadNotifier.notify(s) }
end
