require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Varnish" do
  before(:each) do
    @telnet_mock = mock('Net::Telnet')
    Net::Telnet.stub!(:new).and_return(@telnet_mock)
    @telnet_mock.stub!(:close)
    @telnet_mock.stub!(:cmd)
    @telnet_mock.stub!(:puts)
    @telnet_mock.stub!(:waitfor)
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

    describe "when using authentication" do
      after(:each) do
        Lacquer.configuration.varnish_servers.first[:secret] = nil
      end
      describe "with correct secret" do
        before(:each) do
          Lacquer.configuration.varnish_servers.first[:secret] = "the real secret"
        end

        it "should return successfully when using correct secret" do
          @telnet_mock.stub!(:waitfor).with("Match" => /^107/).and_yield('107 59      \nhaalpffwlcvblmdrinpnjwigwsbiiigq\n\nAuthentication required.\n\n')
          @telnet_mock.stub!(:cmd).with("String" => "auth d218942acc92753db0c9fedddb32cde6158de28e903356caed1808cf0e23a15a", "Match" => /\d{3}/).and_yield('200')
          @telnet_mock.stub!(:cmd).with("String" => "url.purge /", "Match" => /\n\n/).and_yield('200')

          lambda {
            Lacquer::Varnish.new.purge('/')
          }.should_not raise_error
        end

        after(:each) do
          Lacquer.configuration.varnish_servers.first[:secret] = nil
        end
      end

      describe "with wrong secret" do
        before(:each) do
          Lacquer.configuration.varnish_servers.first[:secret] = "the wrong secret"
        end
        it "should raise Lacquer::AuthenticationError when using wrong secret" do
          @telnet_mock.stub!(:waitfor).with("Match" => /^107/).and_yield('107 59      \nhaalpffwlcvblmdrinpnjwigwsbiiigq\n\nAuthentication required.\n\n')
          @telnet_mock.stub!(:cmd).with("String" => "auth 767dc6ec9eca6e4155d20c8479d3a1a10cf88d92c3846388a830d7fd966d58f9", "Match" => /\d{3}/).and_yield('107')
          @telnet_mock.stub!(:cmd).with("url.purge /").and_yield('200')

          lambda {
            Lacquer::Varnish.new.purge('/')
          }.should raise_error(Lacquer::VarnishError)
        end
        after(:each) do
          Lacquer.configuration.varnish_servers.first[:secret] = nil
        end
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
      @telnet_mock.stub!(:cmd).and_yield(%Q[
200 2023
     6263596  Client connections accepted
     6260911  Client requests received
      919605  Cache hits for pass
     2123848  Cache misses
     6723161  Backend conn. success
     6641493  Fetch with Length
       81512  Fetch wanted close
          11  Fetch failed
        1648  N struct sess_mem
          81  N struct sess
       22781  N struct object
       23040  N struct objectcore
       36047  N struct objecthead
       56108  N struct smf
        1646  N small free smf
         263  N large free smf
          55  N struct vbe_conn
         804  N worker threads
        1583  N worker threads created
        2114  N worker threads limited
        1609  N overflowed work requests
           1  N backends
     1693663  N expired objects
      400637  N LRU nuked objects
          10  N LRU moved objects
         254  HTTP header overflows
     2506470  Objects sent with write
     6263541  Total Sessions
     6260911  Total Requests
          40  Total pipe
     4599215  Total pass
     6722994  Total fetch
  2607029095  Total header bytes
 55280196533  Total body bytes
     6263536  Session Closed
           5  Session herd
   511352337  SHM records
    33376035  SHM writes
       33177  SHM flushes due to overflow
      208858  SHM MTX contention
         246  SHM cycles through buffer
     6361382  allocator requests
       54199  outstanding allocations
   953389056  bytes allocated
   120352768  bytes free
         323  SMS allocator requests
      151528  SMS bytes allocated
      151528  SMS bytes freed
     6723053  Backend requests made
           1  N vcl total
           1  N vcl available
          49  N total active purges
         197  N new purges added
         148  N old purges deleted
        6117  N objects tested
       60375  N regexps tested against
         140  N duplicate purges removed
      944407  HCB Lookups without lock
           3  HCB Lookups with lock
     2099076  HCB Inserts
      515351  Objects ESI parsed (unlock)
       35371  Client uptime

500 22
Closing CLI connection
].strip)
      stats = Lacquer::Varnish.new.stats
      stats.size.should be(1)
    end
  end

  describe "when sending a purge command" do 
    it "should return successfully" do
      @telnet_mock.stub!(:cmd).with("String" => "url.purge /", "Match" => /\n\n/).and_yield('200')
      Lacquer::Varnish.new.purge('/').should be(true)
    end
  end
end
