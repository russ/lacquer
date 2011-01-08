namespace :varnishd do
  
  desc "Start a varnishd daemon using Lacquer's settings"
  task :start => :environment do    
    options = { 
      "-P" => Rails.root.join('log/varnishd.pid'), 
      "-a" => VARNISH_CONFIG[:listen], 
      "-T" => VARNISH_CONFIG[:telnet],
      "-s" => eval(%Q("#{VARNISH_CONFIG[:storage]}")),
      "-f" => Rails.root.join('config/varnish.vcl'),
    }    
    
    params_str = VARNISH_CONFIG[:params].map { |k, v| "-p #{k}=#{v}" }.join(" ")
    options_str = options.map { |k, v| "#{k} #{v}" }.join(" ")
    
    cmd = "#{VARNISH_CONFIG[:sbin_path]}/varnishd #{options_str} #{params_str}"
    puts "** [VARNISH] Booting #{cmd}"  
    `#{cmd}`
  end
  
  desc "Stop varnishd daemon using Lacquer's settings"
  task :stop => :environment do
    pidfile = Rails.root.join('log/varnishd.pid')
    
    if pidfile.exist?
      pid = pidfile.read
      cmd = "kill #{pid}"
      puts "** [VARNISH] Killing process with pid #{pid}"
      `#{cmd}`
      pidfile.delete      
    else
      puts "** [VARNISH] pidfile not found"
    end
    
  end
  
  desc "Purge ALL urls from Varnish"
  task :global_purge => :environment do

    #It WILL timeout, just accept it. Varnish does not have a command prompt.
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