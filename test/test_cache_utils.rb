require 'helper'

class ControllerClass
  def self.before_filter(arg); end
  def self.after_filter(arg); end

  include Lacquer::CacheUtils
end

class TestLacquer < ActiveSupport::TestCase
  setup do
    @controller = ControllerClass.new
  end

  should "take paths to clear cache for" do
    Lacquer::VarnishInterface.expects(:send_command).twice
    @controller.clear_cache_for('/', '/blog/posts')
  end

  context "when cache is enabled" do
    should "send cache control headers based on ttl" do
      Lacquer.configuration.enable_cache = true
      @controller.set_cache_ttl(10.week)
      @controller.expects(:expires_in).with(10.week, :public => true)
      @controller.send_cache_control_headers
    end
  end

  context "when cache is disabled" do
    should "do not send cache control headers" do
      Lacquer.configuration.enable_cache = false
      @controller.expects(:expires_in).never
      @controller.send_cache_control_headers
    end
  end
end
