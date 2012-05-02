require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "ResqueJob" do
  describe "perform" do
    it "should purge the parameter" do
      require File.expand_path('lib/lacquer/resque_job')

      @varnish_mock = mock('varnish')
      Lacquer::Varnish.stub!(:new).and_return(@varnish_mock)

      @varnish_mock.should_receive(:purge).with('/').exactly(1).times
      Lacquer::ResqueJob.perform('/')
    end
  end
end
