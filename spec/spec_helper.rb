$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "lacquer"
require "rspec"

class ControllerClass
  def self.before_filter(arg); end
  def self.after_filter(arg); end

  include Lacquer::CacheUtils
end

class SweeperClass
  include Lacquer::CacheUtils
end

module Delayed;
  module Job; end
end

module Resque; end

module Sidekiq
  module Worker
    module ClassMethods
      def sidekiq_options(options); end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end

Lacquer.configure do |config|
  config.enable_cache = true
  config.default_ttl = 1.week
  config.job_backend = :none
  config.varnish_servers << { :host => "0.0.0.0", :port => 6082 }
end

RSpec.configure do |c|
  c.mock_with :rspec
end
