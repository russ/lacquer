module Lacquer
  class Varnishd
    attr_accessor :listen, :telnet, :sbin_path, :storage, :working_dir, :user, :backend, :params
    
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
      self.listen, self.telnet, self.backend, self.sbin_path, self.storage, self.working_dir, self.user, self.params =
        settings.values_at("listen", "telnet", "backend", "sbin_path", "storage", "working_dir", "user", "params")
    end
    
    def render_vcl      
      require 'erubis'
      eruby = Erubis::Eruby.new(erb_vcl_script_filename.read)
      eruby.result(binding)
    end
    
    def generate_vcl
      if erb_vcl_script_filename.exist?
        log "#{erb_vcl_script_filename} found rendering to #{vcl_script_filename}"
        File.open(vcl_script_filename, "w") do |vcl|
          vcl.write(render_vcl)
        end
      end
    end
    
    def start
      if running?
        log("Already running")
        return
      end
      generate_vcl
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
      opt = {}
      opt["-P"] = pid_file
      opt["-a"] = listen
      opt["-T"] = telnet        if telnet.present?
      opt["-n"] = working_dir   if working_dir.present?
      opt["-u"] = user          if user.present?
      opt["-s"] = eval(%Q("#{storage}"))
      opt["-f"] = vcl_script_filename
      opt
    end
    
    def params
      @params || {}
    end
    
    protected
    
    def varnishd_cmd
      Pathname.new(sbin_path).join('varnishd')
    end
    
    def pid_file
      self.class.root_path.join("log/varnishd.#{self.class.env}.pid")
    end
    
    def vcl_script_filename
      self.class.root_path.join(self.class.vcl_script_filename)
    end
    
    def erb_vcl_script_filename
      vcl_script_filename.sub_ext('.vcl.erb')
    end
    
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