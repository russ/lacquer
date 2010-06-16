require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Varnish" do
  before(:each) do
    @telnet_mock = mock('Net::Telnet')
    Net::Telnet.stub!(:new).and_return(@telnet_mock)
  end

  describe "with any command" do
    describe "when connection is unsuccessful" do
      it "should raise a Lacquer::VarnishError" do
        @telnet_mock.stub!(:cmd).and_raise(Timeout::Error)
        lambda {
          Lacquer::Varnish.new.purge('/')
        }.should raise_error(Lacquer::VarnishError)
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
