namespace :lacquer do
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

    desc "Reload VCL configuration through varnishadm with Lacquer's settings"
    task :reload => :environment do
      varnishd = Lacquer::Varnishd.new
      varnishd.reload
    end

    desc "Purge ALL urls from Varnish"
    task :global_purge => :environment do
      Lacquer::Varnish.new.purge('.*')
    end
  end
end
