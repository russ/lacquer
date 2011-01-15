module Lacquer
  
  def self.cache_control
    @cache_control ||= CacheControl.new
  end
  
  class CacheControl
    include Lacquer::CacheUtils
    attr_accessor :store
    
    def initialize
      self.store = []
    end
  
    def register(group, options = {})
      options[:group]  = group
      options[:args]   = Array(options[:args]).compact
      store           << options
    end
  
    def configure
      yield self
    end
    
    def purge(group, *args)
      clear_cache_for(*urls_for(group, *args))      
    end
    
    def urls_for(group, *args)
      args.map! { |arg| arg.to_param }
      urls_by(group).map { |options| options[:url] % args }
    end
  
    def to_vcl_conditions(urls = store)
      urls.map { |opt| %Q[req.url ~ "#{(opt[:url] % opt[:args])}"] }.join(" || ")
    end
    
    def to_vcl_override_ttl_urls
      urls_grouped_by_expires.map do |expires_in, list|
        <<-CODE.strip_heredoc
        if(#{to_vcl_conditions(list)}) {
          unset beresp.http.Set-Cookie;
          set beresp.ttl = #{expires_in};
          return(deliver);
        }
        CODE
      end.join("\n")
    end
    
    protected
    
    def urls_grouped_by_expires
      store.group_by { |opt| opt[:expires_in] }.select { |expires_in, list| expires_in }
    end
    
    def urls_by(group)
      store.select   { |opt| opt[:group] == group }
    end
  
  end  
end
