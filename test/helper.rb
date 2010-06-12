require 'rubygems'
require 'active_support'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lacquer'

class ControllerClass
  def self.before_filter(arg); end
  def self.after_filter(arg); end

  include Lacquer::CacheUtils
end

module Delayed;
  module Job; end
end

module Resque; end

class ActiveSupport::TestCase
end
