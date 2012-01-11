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
  # config.command_error_handler = lambda { |s| HoptoadNotifier.notify(s) }


  ### Varnish - 2.x  /  3.x  .. VCL-Changes
  ### https://www.varnish-cache.org/docs/trunk/installation/upgrade.html

  # => Purge Command  ( "url.purge" for Varnish 2.x .. "ban.url" for Varnish 3.x )
  # => purges are now called bans in Varnish 3.x .. purge() and purge_url() are now respectively ban() and ban_url()
  config.purge_command = "url.purge"

  # => VCL_Fetch Pass Command  ( "pass" for Varnish 2.x .. "hit_for_pass" for Varnish 3.x )
  # => pass in vcl_fetch renamed to hit_for_pass in Varnish 3.x   
  config.pass_command = "pass"
end
