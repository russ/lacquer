Lacquer.configure do |config|
  config.enable_cache = true
  config.default_ttl = 1.week
  config.varnish_servers << { :host => '0.0.0.0', :port => 6082 }
end
