module Lacquer
  module CacheUtils
    def self.included(base)
      base.class_eval do
        attr_reader :cache_ttl

        before_filter :set_default_cache_ttl
        after_filter :send_cache_control_headers
      end
    end

    # Instance variable for the action ttl.
    def set_cache_ttl(ttl)
      @cache_ttl = ttl
    end

    # Called as a before filter to set default ttl
    # for the entire application.
    def set_default_cache_ttl
      set_cache_ttl(Lacquer.configuration.default_ttl)
    end

    # Sends url.purge command to varnish to clear cache.
    #
    # clear_cache_for(root_path, blog_posts_path, '/other/content/*')
    def clear_cache_for(*paths)
      paths.each do |path|
        VarnishInterface.send_command('url.purge ' << path)
      end
    end
    
    # Sends cache control headers with page.
    # These are the headers that varnish responds to
    # to set cache properly.
    def send_cache_control_headers
      if Lacquer.configuration.enable_cache
        expires_in(@cache_ttl, :public => true)
      end
    end
  end
end
