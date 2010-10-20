require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Lacquer" do
  before(:each) do
    @controller = ControllerClass.new
  end

  describe "talking to varnish" do
    before(:each) do
      @varnish_stub = mock('varnish')
      Lacquer::Varnish.stub!(:new).and_return(@varnish_stub)
    end

    describe "when backend is :none" do
      before(:each) do
        Lacquer.configuration.job_backend = :none
      end

      it "sends commands to varnish instantly" do
        @varnish_stub.should_receive(:purge).twice
        @controller.clear_cache_for('/', '/blog/posts')
      end

      it "calls purge with the correct parameter" do
        @varnish_stub.should_receive(:purge).with('/')
        @controller.clear_cache_for('/')
      end
    end

    describe "when backend is :delayed_job" do
      it "sends commands to a delayed_job queue" do
        Lacquer.configuration.job_backend = :delayed_job

        Delayed::Job.should_receive(:enqueue).twice
        @controller.clear_cache_for('/', '/blog/posts')
      end
    end

    describe "when backend is :resque" do
      it "sends commands to a resque queue" do
        Lacquer.configuration.job_backend = :resque

        Resque.should_receive(:enqueue).twice
        @controller.clear_cache_for('/', '/blog/posts')
      end
    end
  end

  describe "when cache is enabled" do
    describe "when no custom ttl is set" do
      it "should send cache control headers based on default ttl" do
        Lacquer.configuration.enable_cache = true
        Lacquer.configuration.default_ttl = 1.week

        @controller.set_default_cache_ttl
        @controller.should_receive(:expires_in).with(1.week, :public => true)
        @controller.send_cache_control_headers
      end
    end

    describe "when custom ttl is set" do
      it "should send cache control headers based on custom set ttl" do
        Lacquer.configuration.enable_cache = true

        @controller.set_cache_ttl(10.week)
        @controller.should_receive(:expires_in).with(10.week, :public => true)
        @controller.send_cache_control_headers
      end
    end
  end

  it "should allow purge by non-controller sweepers" do
    @varnish_stub = mock('varnish')
    Lacquer::Varnish.stub!(:new).and_return(@varnish_stub)

    @sweeper = SweeperClass.new

    @varnish_stub.should_receive(:purge)
    @sweeper.clear_cache_for('/')
  end
end
