module Lacquer
  class Varnishd
    attr_accessor :listen, :telnet, :sbin_path, :storage, :working_dir, :user, :params
    
    cattr_accessor :started_check_delay, :vcl_script_filename
    self.started_check_delay = 1
    self.vcl_script_filename = 'config/varnish.vcl'
    
    def self.root_path
      Rails.root
    end

    def self.env
      Rails.env
    end
    
    def self.config_file
      root_path.join('config/varnishd.yml')
    end
    
    def self.config
      YAML.load(File.read(config_file))[env].stringify_keys
    end
    
    def initialize(settings = self.class.config)
      self.listen, self.telnet, self.sbin_path, self.storage, self.working_dir, self.user, self.params = settings.values_at("listen", "telnet", "sbin_path", "storage", "working_dir", "user", "params")
    end
    
    def varnishd_cmd
      Pathname.new(sbin_path).join('varnishd')
    end
    
    def pid_file
      self.class.root_path.join("log/varnishd.#{self.class.env}.pid")
    end
    
    def vcl_script_path
      vcl_script = self.class.root_path.join(self.class.vcl_script_filename)
      fail "VCL file not found: #{vcl_script} (copy from config/varnish.sample.vcl)" unless vcl_script.exist?
      vcl_script
    end
    
    def start
      if running?
        log("Already running")
        return
      end
      execute("#{varnishd_cmd} #{args} #{params_args}")
      sleep(self.class.started_check_delay)
      log("Failed to start varnishd daemon") unless running?
    end
    
    def stop
      if running?
        execute("kill #{pid}")
        pid_file.delete
      else
        log("pid file not found or varnishd not running")
      end      
    end
    
    def running?
      !!pid && !!Process.kill(0, pid.to_i)
    rescue
      false
    end
    
    def args
      options.map { |k, v| "#{k} #{v}" }.join(" ")
    end
    
    def params_args
      params.map { |k, v| "-p #{k}=#{v}" }.join(" ")
    end

    def options
      { 
        "-P" => pid_file, 
        "-a" => listen, 
        "-T" => telnet,
        "-n" => working_dir,
        "-u" => user,
        "-s" => eval(%Q("#{storage}")),
        "-f" => vcl_script_path,
      }    
    end
    
    def params
      @params || {}
    end
    
    protected
    
    def log(message)
      puts "** [#{self.class.name}] #{message}"
    end
    
    def execute(cmd)
      log(cmd)
      `#{cmd}`
    end
   
    def pid
      if pid_file.exist?
        pid_file.read
      else
        nil
      end
    end
    
  end
end