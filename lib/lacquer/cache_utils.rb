module Lacquer
  module CacheUtils
    def self.included(base)
      base.class_eval do
        attr_reader :cache_ttl

        before_filter :set_cache_ttl
        after_filter :send_cache_control_headers
      end
    end

    def set_cache_ttl(ttl = 1.week)
      @cache_ttl = ttl
    end

    def clear_cache_for(*paths)
      paths.each do |path|
        VarnishInterface.send_command('url.purge ' << path)
      end
    end
    
    def send_cache_control_headers
      unless Rails.env == 'development'
        expires_in(@cache_ttl, :public => true)
      end
    end
  end
end
