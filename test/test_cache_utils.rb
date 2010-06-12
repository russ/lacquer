require 'helper'

class ControllerClass
  def self.before_filter(arg); end
  def self.after_filter(arg); end

  include Lacquer::CacheUtils
end

class Rails
  class << self
    attr_accessor :env
  end
end

class TestLacquer < ActiveSupport::TestCase
  setup do
    @controller = ControllerClass.new
  end

  should "take paths to clear cache for" do
    Lacquer::VarnishInterface.expects(:send_command).twice
    @controller.clear_cache_for('/', '/blog/posts')
  end

  should "send cache control headers based on ttl" do
    @controller.set_cache_ttl(100)
    @controller.expects(:expires_in).with(100, :public => true)
    @controller.send_cache_control_headers
  end
end
