module Lacquer
  class CacheControl
    include Lacquer::CacheUtils
    STORE = {}
  
    def register(group, options = {})
      STORE[group]   ||= []
      options[:args]   = Array(options[:args]).compact
      STORE[group]    << options
    end
  
    def configure
      yield self
    end
    
    def purge(group, *args)
      clear_cache_for(*STORE[group].map { |options| options[:url] % args.map { |arg| arg.to_param } })      
    end
  
    def to_vcl
      STORE.map do |group, options|
        options.map do |option|
          "req.url ~ #{(option[:url] % option[:args])}"          
        end
      end.flatten.join(" ||\n")
    end
  
  end
end
