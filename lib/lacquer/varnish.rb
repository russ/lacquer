module Lacquer
  class Varnish
    def stats
      stats = send_command('stats').split("\n")
      stats.shift
      
      stats = stats.collect do |stat|
        stat = stat.strip.match(/(\d+)\s+(.+)$/)
        { :key => stat[2], :value => stat[1] }
      end
    end

    def purge(path)
      (send_command('url.purge ' << path) == '200 0') ? true : false
    end

  private

    # Sends commands over telnet to varnish servers listed in the config.
    def send_command(command)
      Lacquer.configuration.varnish_servers.each do |server|
        begin
          connection = Net::Telnet.new(
            'Host' => server[:host],
            'Port' => server[:port],
            'Timeout' => server[:timeout] || 5)
          connection.cmd(command) do |c|
            return c.strip
          end
        rescue Exception => e
          raise VarnishError.new("Error while trying to connect to #{server[:host]}:#{server[:port]} #{e}")
        end
      end
    end
  end
end
