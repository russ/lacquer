namespace :varnishd do
  
  desc "Start varnishd daemon using Lacquer's settings"
  task :start => :environment do
    Lacquer::Varnishd.new.start
  end
  
  desc "Stop varnishd daemon using Lacquer's settings"
  task :stop => :environment do
    Lacquer::Varnishd.new.stop
  end
  
  desc "Running status of varnishd daemon using Lacquer's settings"
  task :status => :environment do
    if Lacquer::Varnishd.new.running?
      puts "Varnishd is running"
    else
      puts "Varnishd is not running"
    end
  end
  
  desc "Restart varnishd daemon using Lacquer's settings"
  task :restart => :environment do
    varnishd = Lacquer::Varnishd.new
    if varnishd.running?
      varnishd.stop
      sleep(1)
    end
    varnishd.start
  end
  
  desc "Purge ALL urls from Varnish"
  task :global_purge => :environment do

    # It WILL timeout, just accept it. Varnish does not have a command prompt.
    require 'net/telnet'
    @result = ""
    begin
      localhost = Net::Telnet::new("Host" => "localhost", "Port" => 6082, "Timeout" => 5)
      localhost.cmd("url.purge .*") { |c| @result = c}
    rescue Exception
      if @result.include? ("200 0")
        puts "varnish purged OK."
      else
        raise "Varnish not purged."
      end
    end
    
  end
    
end