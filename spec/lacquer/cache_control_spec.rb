require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')
require 'lacquer/cache_control'

describe Lacquer::CacheControl do
  describe "#register" do
    it "persists cache settings for url" do
      cache_control = described_class.new
      cache_control.register :class_section, :url => "^/sv/class_sections/%s.*$", :args => "[0-9]+"
      cache_control.store.first[:group].should  == :class_section
      cache_control.store.first[:url].should    == "^/sv/class_sections/%s.*$"
      cache_control.store.first[:args].should   == ["[0-9]+"]
    end
  end
  
  describe "#urls_for" do
    it "returns urls to expire for object" do      
      cache_control = described_class.new
      cache_control.register :class_section, :url => "^/sv/class_sections/%s.*$", :args => "[0-9]+"
      cache_control.urls_for(:class_section, mock("ClassSection", :to_param => 1)).should == ["^/sv/class_sections/1.*$"]
    end
  end

  context "vcl" do
    it "returns all urls as vcl conditions" do
      cache_control = described_class.new
      cache_control.register :class_section, :url => "^/sv/class_sections/%s.*$", :args => "[0-9]+"
      cache_control.register :class_section, :url => "^/sv/info_screens/%s.*$", :args => "[0-9]+"
      
      conditions = cache_control.to_vcl_conditions
      conditions.should include("req.url ~ \"^/sv/class_sections/[0-9]+.*$\"")
      conditions.should include("||")
      conditions.should include("req.url ~ \"^/sv/info_screens/[0-9]+.*$\"")
    end

    it "returns vcl for pass urls" do
      cache_control = described_class.new
      cache_control.register :pass, :url => "^/admin"
      pass_urls = cache_control.to_vcl_pass_urls
      pass_urls.should include('if(req.url ~ "^/admin")')
      pass_urls.should include('return(pass)')
    end

    it "returns vcl for pipe urls" do
      cache_control = described_class.new
      cache_control.register :pipe, :url => "*.mp4$"
      pass_urls = cache_control.to_vcl_pipe_urls
      pass_urls.should include('if(req.url ~ "*.mp4$")')
      pass_urls.should include('return(pipe)')
    end
    
    it "returns vcl for override ttl on beresp" do
      cache_control = described_class.new
      cache_control.register :class_section, :url => "^/sv/competitions$", :expires_in => "7d"
      override_ttl = cache_control.to_vcl_override_ttl_urls
      override_ttl.should include('if(req.url ~ "^/sv/competitions$")')
      override_ttl.should include('unset beresp.http.Set-Cookie')
      override_ttl.should include('return(deliver)')
    end
    
    it "group by expires in" do
      cache_control = described_class.new
      cache_control.register :class_section, :url => "^/sv/competitions$", :expires_in => "1d"
      cache_control.register :class_section, :url => "^/sv/competitions/%s$", :args => "[0-9]+", :expires_in => "2d"
      cache_control.register :class_section, :url => "^/sv/competitions/%s/info_screen$", :args => "[0-9]+"
      
      override_ttl = cache_control.to_vcl_override_ttl_urls
      override_ttl.should include('if(req.url ~ "^/sv/competitions$")')
      override_ttl.should include('set beresp.ttl = 1d')
      override_ttl.should include('if(req.url ~ "^/sv/competitions/[0-9]+$")')
      override_ttl.should include('set beresp.ttl = 2d')
      override_ttl.should_not include('info_screen')
    end
  end
end
