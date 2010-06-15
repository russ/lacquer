require 'helper'

class TestLacquer < ActiveSupport::TestCase
  setup do
    Lacquer.configure do |config|
      config.varnish_servers << { :host => '0.0.0.0', :port => 6082 }
    end 

    @telnet_mock = mock('Net::Telnet')
    @telnet_mock.stubs(:cmd)

    @controller = ControllerClass.new
  end

  context "when connection is succesful" do
    should "send command to varnish server" do
      Net::Telnet.stubs(:new).returns(@telnet_mock)
      Lacquer::Varnish.new.purge('/')
    end
  end

  context "when connection is unsuccesful" do
    should "raise timeout exception" do
      Net::Telnet.stubs(:new).raises(Timeout::Error)
      assert_raise Lacquer::VarnishError do
        Lacquer::Varnish.new.purge('/')
      end
    end
  end
end
