module Lacquer
  class Varnish
    def stats
      send_command('stats').collect do |stats|
        stats = stats.split("\n")
        stats.shift
      
        stats = stats.collect do |stat|
          stat = stat.strip.match(/(\d+)\s+(.+)$/)
          { :key => stat[2], :value => stat[1] }
        end
      end
    end

    def purge(path)
      send_command('url.purge ' << path).all? do |result|
        result =~ /200/
      end
    end

  private

    # Sends commands over telnet to varnish servers listed in the config.
    def send_command(command)
      Lacquer.configuration.varnish_servers.collect do |server|
        begin
          connection = Net::Telnet.new(
            'Host' => server[:host],
            'Port' => server[:port],
            'Timeout' => server[:timeout] || 5)
          connection.cmd(command) do |c|
            c.strip
          end
        rescue Exception => e
          raise VarnishError.new("Error while trying to connect to #{server[:host]}:#{server[:port]} #{e}")
        end
      end
    end
  end
end
