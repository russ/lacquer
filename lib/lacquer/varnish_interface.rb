module Lacquer
  class VarnishInterface
    # Sends commands over telnet to varnish servers listed in the config.
    def self.send_command(command)
      Lacquer.configuration.varnish_servers.each do |server|
        begin
          connection = Net::Telnet.new(
            'Host' => server[:host],
            'Port' => server[:port],
            'Timeout' => server[:timeout] || 5)
          connection.puts(command)
        rescue Exception => e
          raise VarnishError.new("Error while trying to connect to #{server[:host]}:#{server[:port]} #{e}")
        end
      end
    end
  end
end
