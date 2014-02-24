module Lacquer
  class Varnish
    def stats
      send_command('stats').collect do |stats|
        stats = stats.split("\n")
        stats.shift
        stats = stats.collect do |stat|
          stat = stat.strip.match(/(\d+)\s+(.+)$/)
          { :key => stat[2], :value => stat[1] } if stat
        end
      end
    end

    # Sends the command 'url.purge *path*'
    def purge(*paths)
      paths.all? do |path|
        ActiveSupport::Notifications.instrument('purge.lacquer', path: path) do |payload|
          send_command(Lacquer.configuration.purge_command + " " + path.gsub('\\', '\\\\\\')).all? do |result|
            payload[:result] = result
            result =~ /200/
          end
        end
      end
    end

    # Sends commands over telnet to varnish servers listed in the config.
    def send_command(command)
      Lacquer.configuration.varnish_servers.collect do |server|
        retries = 0
        response = nil
        begin
          retries += 1
          connection = Net::Telnet.new(
            'Host' => server[:host],
            'Port' => server[:port],
            'Timeout' => server[:timeout] || 5)

          if(server[:secret])
            connection.waitfor("Match" => /^107/) do |authentication_request|
              matchdata = /^107 \d{2}\s*(.{32}).*$/m.match(authentication_request) # Might be a bit ugly regex, but it works great!
              salt = matchdata[1]
              if(salt.empty?)
                raise VarnishError, "Bad authentication request"
              end

              digest = OpenSSL::Digest::SHA256.new
              digest << salt
              digest << "\n"
              digest << server[:secret]
              digest << salt
              digest << "\n"

              connection.cmd("String" => "auth #{digest.to_s}", "Match" => /\d{3}/) do |auth_response|
                if(!(/^200/ =~ auth_response))
                  raise AuthenticationError, "Could not authenticate"
                end
              end
            end
          end

          connection.cmd('String' => command, 'Match' => /\n\n/) {|r| response = r.split("\n").first.strip}
          connection.close if connection.respond_to?(:close)
        rescue Exception => e
          if retries < Lacquer.configuration.retries
            retry
          else
            if Lacquer.configuration.command_error_handler
              Lacquer.configuration.command_error_handler.call({
               :error_class   => "Varnish Error, retried #{Lacquer.configuration.retries} times",
               :error_message => "Error while trying to connect to #{server[:host]}:#{server[:port]}: #{e}",
               :parameters    => server,
               :response      => response })
            elsif e.kind_of?(Lacquer::AuthenticationError)
              raise e
            else
              raise VarnishError.new("Error while trying to connect to #{server[:host]}:#{server[:port]} #{e}")
            end
          end
        end
        response
      end
    end
  end
end
