require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Varnish" do
  before(:each) do
    @telnet_mock = mock('Net::Telnet')
    Net::Telnet.stub!(:new).and_return(@telnet_mock)
    @telnet_mock.stub!(:close)
    @telnet_mock.stub!(:cmd)    
    Lacquer.configuration.retries.should == 5
  end

  describe "with any command" do
    describe "when connection is unsuccessful" do
      it "should raise a Lacquer::VarnishError" do
        @telnet_mock.stub!(:cmd).and_raise(Timeout::Error)
        lambda {
          Lacquer::Varnish.new.purge('/')
        }.should raise_error(Lacquer::VarnishError)
      end
      
      it "should retry on failure before erroring" do
        @telnet_mock.stub!(:cmd).and_raise(Timeout::Error)
        Net::Telnet.should_receive(:new).exactly(5).times
        lambda {
          Lacquer::Varnish.new.purge('/')
        }.should raise_error(Lacquer::VarnishError)
      end
      
      it "should close the connection afterwards" do
        @telnet_mock.should_receive(:close).exactly(1).times
        Lacquer::Varnish.new.purge('/')
      end
    end
    
    describe "when connection is unsuccessful and an error handler is set" do
      before(:each) do
        Lacquer.configuration.command_error_handler = mock("command_error_handler")
      end
      it "should call handler on error" do
        @telnet_mock.stub!(:cmd).and_raise(Timeout::Error)
        Lacquer.configuration.command_error_handler.should_receive(:call).exactly(1).times
        lambda {
          Lacquer::Varnish.new.purge('/')
        }.should_not raise_error(Lacquer::VarnishError)
      end
    end
  end 
  
  describe "when sending a stats command" do
    it "should return an array of stats" do
      @telnet_mock.stub!(:cmd).and_yield("200 200\n1000 Connections")
      stats = Lacquer::Varnish.new.stats
      stats.size.should be(1)
    end
  end

  describe "when sending a purge command" do 
    it "should return successfully" do
      @telnet_mock.stub!(:cmd).and_yield('200')
      Lacquer::Varnish.new.purge('/').should be(true)
    end
  end
end
